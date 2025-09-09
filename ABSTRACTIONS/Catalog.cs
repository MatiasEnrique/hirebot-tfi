using System;
using System.Collections.Generic;

namespace ABSTRACTIONS
{
    public class Catalog
    {
        public int CatalogId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public int CreatedByUserId { get; set; }
        public List<int> ProductIds { get; set; }

        public Catalog()
        {
            CreatedDate = DateTime.Now;
            IsActive = true;
            ProductIds = new List<int>();
        }
    }

    public class CatalogProduct
    {
        public int CatalogId { get; set; }
        public int ProductId { get; set; }
        public DateTime AddedDate { get; set; }
        public int AddedByUserId { get; set; }

        public CatalogProduct()
        {
            AddedDate = DateTime.Now;
        }
    }
}