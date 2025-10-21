using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using ABSTRACTIONS;

namespace DAL
{
    /// <summary>
    /// Data Access Layer for Organization operations
    /// Implements raw SQL queries calling stored procedures exclusively
    /// Handles all database operations for organizations and organization members
    /// </summary>
    public class OrganizationDAL
    {
        public OrganizationDAL()
        {
        }

        #region Organization CRUD Operations

        /// <summary>
        /// Creates a new organization using sp_CreateOrganization
        /// </summary>
        /// <param name="name">Organization name</param>
        /// <param name="slug">Organization slug (unique identifier)</param>
        /// <param name="description">Organization description (optional)</param>
        /// <param name="ownerId">ID of the organization owner</param>
        /// <param name="createdBy">ID of the user creating the organization</param>
        /// <returns>DatabaseResult with the new organization ID</returns>
        public DatabaseResult<int> CreateOrganization(string name, string slug, string description, int ownerId, int createdBy)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_CreateOrganization", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandTimeout = 30;

                        // Add parameters matching stored procedure signature
                        command.Parameters.Add(new SqlParameter("@Name", SqlDbType.NVarChar, 100) { Value = name ?? (object)DBNull.Value });
                        command.Parameters.Add(new SqlParameter("@Slug", SqlDbType.NVarChar, 50) { Value = slug ?? (object)DBNull.Value });
                        command.Parameters.Add(new SqlParameter("@Description", SqlDbType.NVarChar, 500) { Value = description ?? (object)DBNull.Value });
                        command.Parameters.Add(new SqlParameter("@OwnerId", SqlDbType.Int) { Value = ownerId });
                        command.Parameters.Add(new SqlParameter("@CreatedBy", SqlDbType.Int) { Value = createdBy });

                        connection.Open();

                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // Check if the result is null or DBNull
                                if (reader.IsDBNull(0))
                                {
                                    return DatabaseResult<int>.Failure("Organization creation failed - no ID returned");
                                }
                                
                                // Safely get the organization ID
                                object orgIdValue = reader.GetValue(0);
                                if (orgIdValue == null || orgIdValue == DBNull.Value)
                                {
                                    return DatabaseResult<int>.Failure("Organization creation failed - null ID returned");
                                }
                                
                                // Try to convert to int
                                if (int.TryParse(orgIdValue.ToString(), out int organizationId))
                                {
                                    return DatabaseResult<int>.Success(organizationId, "Organization created successfully");
                                }
                                else
                                {
                                    return DatabaseResult<int>.Failure($"Invalid organization ID returned: {orgIdValue}");
                                }
                            }
                            else
                            {
                                return DatabaseResult<int>.Failure("Organization creation failed - stored procedure returned no results");
                            }
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                return DatabaseResult<int>.Failure($"Database error creating organization: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                return DatabaseResult<int>.Failure($"Unexpected error creating organization: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets organization details by ID using sp_GetOrganizationById
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <returns>OrganizationResult with organization details</returns>
        public OrganizationResult GetOrganizationById(int organizationId)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetOrganizationById", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandTimeout = 30;

                        command.Parameters.Add(new SqlParameter("@OrganizationId", SqlDbType.Int) { Value = organizationId });

                        connection.Open();

                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                var organization = MapOrganizationFromReader(reader);
                                return OrganizationResult.Success(organization, "Organization retrieved successfully");
                            }
                            else
                            {
                                return OrganizationResult.Failure("Organization not found");
                            }
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                return OrganizationResult.Failure($"Database error retrieving organization: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                return OrganizationResult.Failure($"Unexpected error retrieving organization: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets organization details by slug using sp_GetOrganizationBySlug
        /// </summary>
        /// <param name="slug">Organization slug</param>
        /// <returns>OrganizationResult with organization details</returns>
        public OrganizationResult GetOrganizationBySlug(string slug)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetOrganizationBySlug", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandTimeout = 30;

                        command.Parameters.Add(new SqlParameter("@Slug", SqlDbType.NVarChar, 50) { Value = slug ?? (object)DBNull.Value });

                        connection.Open();

                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                var organization = MapOrganizationFromReader(reader);
                                return OrganizationResult.Success(organization, "Organization retrieved successfully");
                            }
                            else
                            {
                                return OrganizationResult.Failure("Organization not found");
                            }
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                return OrganizationResult.Failure($"Database error retrieving organization: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                return OrganizationResult.Failure($"Unexpected error retrieving organization: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets all organizations with pagination using sp_GetAllOrganizations
        /// </summary>
        /// <param name="pageNumber">Page number (default: 1)</param>
        /// <param name="pageSize">Page size (default: 10)</param>
        /// <param name="sortColumn">Sort column (default: Name)</param>
        /// <param name="sortDirection">Sort direction (default: ASC)</param>
        /// <param name="searchTerm">Search term (optional)</param>
        /// <returns>OrganizationListResult with paginated results</returns>
        public OrganizationListResult GetAllOrganizations(int pageNumber = 1, int pageSize = 10, string sortColumn = "Name", string sortDirection = "ASC", string searchTerm = null)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetAllOrganizations", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandTimeout = 30;

                        command.Parameters.Add(new SqlParameter("@PageNumber", SqlDbType.Int) { Value = pageNumber });
                        command.Parameters.Add(new SqlParameter("@PageSize", SqlDbType.Int) { Value = pageSize });
                        command.Parameters.Add(new SqlParameter("@SortColumn", SqlDbType.NVarChar, 50) { Value = sortColumn ?? "Name" });
                        command.Parameters.Add(new SqlParameter("@SortDirection", SqlDbType.NVarChar, 4) { Value = sortDirection ?? "ASC" });
                        command.Parameters.Add(new SqlParameter("@SearchTerm", SqlDbType.NVarChar, 100) { Value = searchTerm ?? (object)DBNull.Value });

                        connection.Open();

                        var organizations = new List<Organization>();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                try
                                {
                                    var organization = MapOrganizationFromReader(reader);
                                    // Map pagination properties
                                    organization.TotalCount = GetNullableInt(reader, "TotalCount");
                                    organization.TotalPages = GetNullableInt(reader, "TotalPages");
                                    organization.RowNum = GetNullableInt(reader, "RowNum");
                                    organizations.Add(organization);
                                }
                                catch (Exception ex)
                                {
                                    // Log detailed column information
                                    var columnInfo = new System.Text.StringBuilder();
                                    for (int i = 0; i < reader.FieldCount; i++)
                                    {
                                        columnInfo.AppendLine($"Column {i}: {reader.GetName(i)} = {(reader.IsDBNull(i) ? "NULL" : reader.GetValue(i)?.ToString())} (Type: {reader.GetFieldType(i)})");
                                    }
                                    
                                    return OrganizationListResult.Failure($"Casting error in row: {ex.Message}. Column details: {columnInfo}", ex);
                                }
                            }
                        }

                        return OrganizationListResult.Success(organizations, "Organizations retrieved successfully");
                    }
                }
            }
            catch (SqlException ex)
            {
                return OrganizationListResult.Failure($"Database error retrieving organizations: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                return OrganizationListResult.Failure($"Unexpected error retrieving organizations: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Updates organization details using sp_UpdateOrganization
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="name">Organization name</param>
        /// <param name="slug">Organization slug</param>
        /// <param name="description">Organization description (optional)</param>
        /// <param name="modifiedBy">ID of user making the update</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult UpdateOrganization(int organizationId, string name, string slug, string description, int modifiedBy)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_UpdateOrganization", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandTimeout = 30;

                        command.Parameters.Add(new SqlParameter("@OrganizationId", SqlDbType.Int) { Value = organizationId });
                        command.Parameters.Add(new SqlParameter("@Name", SqlDbType.NVarChar, 100) { Value = name ?? (object)DBNull.Value });
                        command.Parameters.Add(new SqlParameter("@Slug", SqlDbType.NVarChar, 50) { Value = slug ?? (object)DBNull.Value });
                        command.Parameters.Add(new SqlParameter("@Description", SqlDbType.NVarChar, 500) { Value = description ?? (object)DBNull.Value });
                        command.Parameters.Add(new SqlParameter("@ModifiedBy", SqlDbType.Int) { Value = modifiedBy });

                        connection.Open();
                        command.ExecuteNonQuery();

                        return DatabaseResult.Success("Organization updated successfully");
                    }
                }
            }
            catch (SqlException ex)
            {
                return DatabaseResult.Failure($"Database error updating organization: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error updating organization: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Soft deletes an organization using sp_DeleteOrganization
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="deletedBy">ID of user performing deletion</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult DeleteOrganization(int organizationId, int deletedBy)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_DeleteOrganization", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandTimeout = 30;

                        command.Parameters.Add(new SqlParameter("@OrganizationId", SqlDbType.Int) { Value = organizationId });
                        command.Parameters.Add(new SqlParameter("@DeletedBy", SqlDbType.Int) { Value = deletedBy });

                        connection.Open();
                        command.ExecuteNonQuery();

                        return DatabaseResult.Success("Organization deleted successfully");
                    }
                }
            }
            catch (SqlException ex)
            {
                return DatabaseResult.Failure($"Database error deleting organization: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error deleting organization: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets all organizations owned by a specific user using sp_GetOrganizationsByOwner
        /// </summary>
        /// <param name="ownerId">Owner user ID</param>
        /// <returns>OrganizationListResult with owned organizations</returns>
        public OrganizationListResult GetOrganizationsByOwner(int ownerId)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetOrganizationsByOwner", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandTimeout = 30;

                        command.Parameters.Add(new SqlParameter("@OwnerId", SqlDbType.Int) { Value = ownerId });

                        connection.Open();

                        var organizations = new List<Organization>();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var organization = MapOrganizationFromReader(reader);
                                organizations.Add(organization);
                            }
                        }

                        return OrganizationListResult.Success(organizations, "Owner organizations retrieved successfully");
                    }
                }
            }
            catch (SqlException ex)
            {
                return OrganizationListResult.Failure($"Database error retrieving owner organizations: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                return OrganizationListResult.Failure($"Unexpected error retrieving owner organizations: {ex.Message}", ex);
            }
        }

        #endregion

        #region Organization Member Operations

        /// <summary>
        /// Adds a user to an organization using sp_AddOrganizationMember
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="userId">User ID to add</param>
        /// <param name="role">Member role (default: member)</param>
        /// <param name="addedBy">ID of user adding the member</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult AddOrganizationMember(int organizationId, int userId, string role, int addedBy)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_AddOrganizationMember", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandTimeout = 30;

                        command.Parameters.Add(new SqlParameter("@OrganizationId", SqlDbType.Int) { Value = organizationId });
                        command.Parameters.Add(new SqlParameter("@UserId", SqlDbType.Int) { Value = userId });
                        command.Parameters.Add(new SqlParameter("@Role", SqlDbType.NVarChar, 50) { Value = role ?? "member" });
                        command.Parameters.Add(new SqlParameter("@AddedBy", SqlDbType.Int) { Value = addedBy });

                        connection.Open();
                        command.ExecuteNonQuery();

                        return DatabaseResult.Success("Organization member added successfully");
                    }
                }
            }
            catch (SqlException ex)
            {
                return DatabaseResult.Failure($"Database error adding organization member: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error adding organization member: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Removes a user from an organization using sp_RemoveOrganizationMember
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="userId">User ID to remove</param>
        /// <param name="removedBy">ID of user removing the member</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult RemoveOrganizationMember(int organizationId, int userId, int removedBy)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_RemoveOrganizationMember", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandTimeout = 30;

                        command.Parameters.Add(new SqlParameter("@OrganizationId", SqlDbType.Int) { Value = organizationId });
                        command.Parameters.Add(new SqlParameter("@UserId", SqlDbType.Int) { Value = userId });
                        command.Parameters.Add(new SqlParameter("@RemovedBy", SqlDbType.Int) { Value = removedBy });

                        connection.Open();
                        command.ExecuteNonQuery();

                        return DatabaseResult.Success("Organization member removed successfully");
                    }
                }
            }
            catch (SqlException ex)
            {
                return DatabaseResult.Failure($"Database error removing organization member: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error removing organization member: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets all active members of an organization using sp_GetOrganizationMembers
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="requestingUserId">ID of user requesting the data (for security checks)</param>
        /// <returns>OrganizationMemberListResult with member details</returns>
        public OrganizationMemberListResult GetOrganizationMembers(int organizationId, int? requestingUserId = null)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetOrganizationMembers", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandTimeout = 30;

                        command.Parameters.Add(new SqlParameter("@OrganizationId", SqlDbType.Int) { Value = organizationId });
                        command.Parameters.Add(new SqlParameter("@RequestingUserId", SqlDbType.Int) { Value = requestingUserId ?? (object)DBNull.Value });

                        connection.Open();

                        var members = new List<OrganizationMember>();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var member = MapOrganizationMemberFromReader(reader);
                                members.Add(member);
                            }
                        }

                        return OrganizationMemberListResult.Success(members, "Organization members retrieved successfully");
                    }
                }
            }
            catch (SqlException ex)
            {
                return OrganizationMemberListResult.Failure($"Database error retrieving organization members: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                return OrganizationMemberListResult.Failure($"Unexpected error retrieving organization members: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Gets all organizations a user belongs to using sp_GetUserOrganizations
        /// </summary>
        /// <param name="userId">User ID</param>
        /// <returns>OrganizationMemberListResult with user's organizations</returns>
        public OrganizationMemberListResult GetUserOrganizations(int userId)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetUserOrganizations", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandTimeout = 30;

                        command.Parameters.Add(new SqlParameter("@UserId", SqlDbType.Int) { Value = userId });

                        connection.Open();

                        var userOrganizations = new List<OrganizationMember>();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var member = MapUserOrganizationFromReader(reader);
                                userOrganizations.Add(member);
                            }
                        }

                        return OrganizationMemberListResult.Success(userOrganizations, "User organizations retrieved successfully");
                    }
                }
            }
            catch (SqlException ex)
            {
                return OrganizationMemberListResult.Failure($"Database error retrieving user organizations: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                return OrganizationMemberListResult.Failure($"Unexpected error retrieving user organizations: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Updates a member's role in an organization using sp_UpdateMemberRole
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="userId">User ID</param>
        /// <param name="newRole">New role for the member</param>
        /// <param name="updatedBy">ID of user making the update</param>
        /// <returns>DatabaseResult indicating success or failure</returns>
        public DatabaseResult UpdateMemberRole(int organizationId, int userId, string newRole, int updatedBy)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_UpdateMemberRole", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandTimeout = 30;

                        command.Parameters.Add(new SqlParameter("@OrganizationId", SqlDbType.Int) { Value = organizationId });
                        command.Parameters.Add(new SqlParameter("@UserId", SqlDbType.Int) { Value = userId });
                        command.Parameters.Add(new SqlParameter("@NewRole", SqlDbType.NVarChar, 50) { Value = newRole ?? (object)DBNull.Value });
                        command.Parameters.Add(new SqlParameter("@UpdatedBy", SqlDbType.Int) { Value = updatedBy });

                        connection.Open();
                        command.ExecuteNonQuery();

                        return DatabaseResult.Success("Member role updated successfully");
                    }
                }
            }
            catch (SqlException ex)
            {
                return DatabaseResult.Failure($"Database error updating member role: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                return DatabaseResult.Failure($"Unexpected error updating member role: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Checks if user has specific role in organization using sp_CheckUserOrganizationRole
        /// </summary>
        /// <param name="userId">User ID</param>
        /// <param name="organizationId">Organization ID</param>
        /// <param name="requiredRole">Required role (optional)</param>
        /// <returns>UserOrganizationRoleResult with role information</returns>
        public UserOrganizationRoleResult CheckUserOrganizationRole(int userId, int organizationId, string requiredRole = null)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_CheckUserOrganizationRole", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandTimeout = 30;

                        command.Parameters.Add(new SqlParameter("@UserId", SqlDbType.Int) { Value = userId });
                        command.Parameters.Add(new SqlParameter("@OrganizationId", SqlDbType.Int) { Value = organizationId });
                        command.Parameters.Add(new SqlParameter("@RequiredRole", SqlDbType.NVarChar, 50) { Value = requiredRole ?? (object)DBNull.Value });

                        connection.Open();

                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                bool hasAccess = GetBoolean(reader, "HasAccess");
                                bool isOwner = GetBoolean(reader, "IsOwner");
                                string role = GetString(reader, "Role");
                                int returnedUserId = GetInt32(reader, "UserId");
                                int returnedOrgId = GetInt32(reader, "OrganizationId");

                                return UserOrganizationRoleResult.Success(hasAccess, isOwner, role, returnedUserId, returnedOrgId);
                            }
                            else
                            {
                                return UserOrganizationRoleResult.Failure("No role information returned");
                            }
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                return UserOrganizationRoleResult.Failure($"Database error checking user organization role: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                return UserOrganizationRoleResult.Failure($"Unexpected error checking user organization role: {ex.Message}", ex);
            }
        }

        #endregion

        #region Statistics Operations

        /// <summary>
        /// Gets comprehensive statistics for an organization using sp_GetOrganizationStats
        /// </summary>
        /// <param name="organizationId">Organization ID</param>
        /// <returns>OrganizationStatisticsResult with detailed statistics</returns>
        public OrganizationStatisticsResult GetOrganizationStats(int organizationId)
        {
            try
            {
                using (SqlConnection connection = DatabaseConnectionService.GetConnection())
                {
                    using (SqlCommand command = new SqlCommand("sp_GetOrganizationStats", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandTimeout = 30;

                        command.Parameters.Add(new SqlParameter("@OrganizationId", SqlDbType.Int) { Value = organizationId });

                        connection.Open();

                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                var statistics = MapOrganizationStatisticsFromReader(reader);
                                return OrganizationStatisticsResult.Success(statistics, "Organization statistics retrieved successfully");
                            }
                            else
                            {
                                return OrganizationStatisticsResult.Failure("Organization statistics not found");
                            }
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                return OrganizationStatisticsResult.Failure($"Database error retrieving organization statistics: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                return OrganizationStatisticsResult.Failure($"Unexpected error retrieving organization statistics: {ex.Message}", ex);
            }
        }

        #endregion

        #region Private Helper Methods

        /// <summary>
        /// Maps Organization data from SqlDataReader
        /// </summary>
        private Organization MapOrganizationFromReader(SqlDataReader reader)
        {
            try
            {
                return new Organization
                {
                    Id = GetInt32(reader, "Id"),
                    Name = GetString(reader, "Name"),
                    Slug = GetString(reader, "Slug"),
                    Description = GetString(reader, "Description"),
                    OwnerId = GetInt32(reader, "OwnerId"),
                    CreatedDate = GetDateTime(reader, "CreatedDate"),
                    ModifiedDate = GetNullableDateTime(reader, "ModifiedDate"),
                    IsActive = GetBoolean(reader, "IsActive"),
                    OwnerUsername = GetString(reader, "OwnerUsername"),
                    OwnerFullName = GetString(reader, "OwnerFullName"),
                    MemberCount = GetNullableInt(reader, "MemberCount")
                };
            }
            catch (Exception ex)
            {
                throw new Exception($"Error mapping organization from reader: {ex.Message}. Available columns: {string.Join(", ", Enumerable.Range(0, reader.FieldCount).Select(i => reader.GetName(i)))}", ex);
            }
        }

        /// <summary>
        /// Maps OrganizationMember data from SqlDataReader
        /// </summary>
        private OrganizationMember MapOrganizationMemberFromReader(SqlDataReader reader)
        {
            return new OrganizationMember
            {
                Id = GetInt32(reader, "MembershipId"),
                OrganizationId = GetInt32(reader, "OrganizationId"),
                UserId = GetInt32(reader, "UserId"),
                Username = GetString(reader, "Username"),
                FirstName = GetString(reader, "FirstName"),
                LastName = GetString(reader, "LastName"),
                Email = GetString(reader, "Email"),
                Role = GetString(reader, "Role"),
                JoinedDate = GetDateTime(reader, "JoinedDate"),
                IsActive = GetBoolean(reader, "IsActive"),
                IsOwner = GetBoolean(reader, "IsOwner")
            };
        }

        /// <summary>
        /// Maps user organization data from SqlDataReader (for sp_GetUserOrganizations)
        /// </summary>
        private OrganizationMember MapUserOrganizationFromReader(SqlDataReader reader)
        {
            return new OrganizationMember
            {
                OrganizationId = GetInt32(reader, "OrganizationId"),
                OrganizationName = GetString(reader, "Name"),
                OrganizationSlug = GetString(reader, "Slug"),
                OrganizationDescription = GetString(reader, "Description"),
                OrganizationOwnerId = GetInt32(reader, "OwnerId"),
                OwnerUsername = GetString(reader, "OwnerUsername"),
                OwnerFullName = GetString(reader, "OwnerFullName"),
                UserRole = GetString(reader, "UserRole"),
                JoinedDate = GetDateTime(reader, "JoinedDate"),
                OrganizationCreatedDate = GetDateTime(reader, "CreatedDate"),
                OrganizationModifiedDate = GetNullableDateTime(reader, "ModifiedDate"),
                IsOwner = GetBoolean(reader, "IsOwner"),
                MemberCount = GetNullableInt(reader, "MemberCount")
            };
        }

        /// <summary>
        /// Maps OrganizationStatistics data from SqlDataReader
        /// </summary>
        private OrganizationStatistics MapOrganizationStatisticsFromReader(SqlDataReader reader)
        {
            return new OrganizationStatistics
            {
                Id = GetInt32(reader, "Id"),
                Name = GetString(reader, "Name"),
                Slug = GetString(reader, "Slug"),
                Description = GetString(reader, "Description"),
                CreatedDate = GetDateTime(reader, "CreatedDate"),
                ModifiedDate = GetNullableDateTime(reader, "ModifiedDate"),
                OwnerUsername = GetString(reader, "OwnerUsername"),
                OwnerFullName = GetString(reader, "OwnerFullName"),
                TotalMembers = GetInt32(reader, "TotalMembers"),
                AdminCount = GetInt32(reader, "AdminCount"),
                RegularMemberCount = GetInt32(reader, "RegularMemberCount"),
                FirstMemberJoinDate = GetNullableDateTime(reader, "FirstMemberJoinDate"),
                LastMemberJoinDate = GetNullableDateTime(reader, "LastMemberJoinDate")
            };
        }

        /// <summary>
        /// Safely gets string value from SqlDataReader
        /// </summary>
        private string GetString(SqlDataReader reader, string columnName)
        {
            try
            {
                int ordinal = reader.GetOrdinal(columnName);
                return reader.IsDBNull(ordinal) ? null : reader.GetString(ordinal);
            }
            catch (IndexOutOfRangeException)
            {
                // Column doesn't exist in result set
                return null;
            }
        }

        /// <summary>
        /// Safely gets int32 value from SqlDataReader
        /// </summary>
        private int GetInt32(SqlDataReader reader, string columnName)
        {
            try
            {
                int ordinal = reader.GetOrdinal(columnName);
                if (reader.IsDBNull(ordinal))
                    return 0;
                
                // Handle different numeric types that might be returned
                object value = reader.GetValue(ordinal);
                if (value is int intValue)
                    return intValue;
                if (value is long longValue)
                    return (int)longValue;
                if (value is double doubleValue)
                    return (int)doubleValue;
                if (value is float floatValue)
                    return (int)floatValue;
                if (value is decimal decimalValue)
                    return (int)decimalValue;
                if (value is byte byteValue)
                    return byteValue;
                
                // Try to convert as fallback
                return Convert.ToInt32(value);
            }
            catch (IndexOutOfRangeException)
            {
                // Column doesn't exist in result set
                return 0;
            }
        }

        /// <summary>
        /// Safely gets nullable int32 value from SqlDataReader
        /// </summary>
        private int? GetNullableInt(SqlDataReader reader, string columnName)
        {
            try
            {
                int ordinal = reader.GetOrdinal(columnName);
                if (reader.IsDBNull(ordinal))
                    return null;
                
                // Handle different numeric types that might be returned
                object value = reader.GetValue(ordinal);
                if (value is int intValue)
                    return intValue;
                if (value is long longValue)
                    return (int)longValue;
                if (value is double doubleValue)
                    return (int)doubleValue;
                if (value is float floatValue)
                    return (int)floatValue;
                if (value is decimal decimalValue)
                    return (int)decimalValue;
                if (value is byte byteValue)
                    return byteValue;
                
                // Try to convert as fallback
                return Convert.ToInt32(value);
            }
            catch (IndexOutOfRangeException)
            {
                // Column doesn't exist in result set
                return null;
            }
        }

        /// <summary>
        /// Safely gets DateTime value from SqlDataReader
        /// </summary>
        private DateTime GetDateTime(SqlDataReader reader, string columnName)
        {
            try
            {
                int ordinal = reader.GetOrdinal(columnName);
                return reader.IsDBNull(ordinal) ? DateTime.MinValue : reader.GetDateTime(ordinal);
            }
            catch (IndexOutOfRangeException)
            {
                // Column doesn't exist in result set
                return DateTime.MinValue;
            }
        }

        /// <summary>
        /// Safely gets nullable DateTime value from SqlDataReader
        /// </summary>
        private DateTime? GetNullableDateTime(SqlDataReader reader, string columnName)
        {
            try
            {
                int ordinal = reader.GetOrdinal(columnName);
                return reader.IsDBNull(ordinal) ? (DateTime?)null : reader.GetDateTime(ordinal);
            }
            catch (IndexOutOfRangeException)
            {
                // Column doesn't exist in result set
                return null;
            }
        }

        /// <summary>
        /// Safely gets boolean value from SqlDataReader
        /// </summary>
        private bool GetBoolean(SqlDataReader reader, string columnName)
        {
            try
            {
                int ordinal = reader.GetOrdinal(columnName);
                return reader.IsDBNull(ordinal) ? false : reader.GetBoolean(ordinal);
            }
            catch (IndexOutOfRangeException)
            {
                // Column doesn't exist in result set
                return false;
            }
        }

        #endregion
    }
}