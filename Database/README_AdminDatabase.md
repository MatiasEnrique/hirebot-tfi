# Admin Database Backup and Restore Feature

## Descripción

Esta funcionalidad permite a los administradores crear y restaurar backups de la base de datos Hirebot directamente desde la interfaz web.

## Instalación

### 1. Ejecutar Stored Procedures en el servidor SQL

**IMPORTANTE**: Los stored procedures deben ejecutarse en la base de datos **[master]**, NO en [Hirebot].

1. Abre SQL Server Management Studio (SSMS)
2. Conéctate a tu instancia de SQL Server
3. Selecciona la base de datos **[master]**
4. Abre el archivo: `Database/AdminDatabaseStoredProcedures.sql`
5. Ejecuta el script completo

Los siguientes stored procedures se crearán en [master]:
- `sp_Hirebot_BackupDatabase` - Crea backups completos
- `sp_Hirebot_RestoreDatabase` - Restaura la base de datos desde un backup
- `sp_Hirebot_ListBackups` - Lista archivos .bak en un directorio
- `sp_Hirebot_GetBackupInfo` - Obtiene información sobre un archivo de backup

### 1.5. Agregar Permiso de DatabaseBackup

**IMPORTANTE**: Este paso agrega el permiso en la base de datos [Hirebot] para que aparezca en AdminRoles.

1. En SSMS, selecciona la base de datos **[Hirebot]** (no master)
2. Abre el archivo: `Database/AddDatabaseBackupPermission.sql`
3. Ejecuta el script

Esto agregará el permiso "Gestión de Base de Datos" a la tabla AdminPermission.

**Después de ejecutar el script:**
1. Ve a la página **AdminRoles.aspx** en la aplicación
2. Selecciona el rol "Administrador" (o crea uno nuevo)
3. Marca el checkbox **"Sistema · Gestión de Base de Datos"**
4. Haz clic en **"Guardar cambios"**

Sin este permiso asignado al rol, los usuarios verán el error: "No tiene permisos para realizar esta operación"

### 2. Configurar Permisos

El usuario de SQL Server que utiliza la aplicación necesita permisos especiales para ejecutar estos stored procedures en [master]:

```sql
USE [master]
GO

-- Conceder permisos de ejecución
GRANT EXECUTE ON sp_Hirebot_BackupDatabase TO [tu_usuario_sql]
GRANT EXECUTE ON sp_Hirebot_RestoreDatabase TO [tu_usuario_sql]
GRANT EXECUTE ON sp_Hirebot_ListBackups TO [tu_usuario_sql]
GRANT EXECUTE ON sp_Hirebot_GetBackupInfo TO [tu_usuario_sql]

-- El usuario también necesita permisos para crear y restaurar backups
ALTER SERVER ROLE [dbcreator] ADD MEMBER [tu_usuario_sql]
```

Reemplaza `[tu_usuario_sql]` con el usuario que aparece en tu connection string en web.config.

### 3. Crear Directorio de Backups

Crea un directorio donde se almacenarán los backups. Por ejemplo:

```
C:\Backups\Hirebot
```

Asegúrate de que la cuenta de servicio de SQL Server tenga permisos de lectura/escritura en este directorio.

### 4. Verificar la Compilación

El proyecto ya está configurado. Si hubo cambios en la estructura, ejecuta:

```bash
MSBuild Hirebot-TFI.sln /p:Configuration=Debug
```

## Uso

### Acceder a la Página

1. Inicia sesión como **Administrador**
2. En el menú lateral izquierdo, busca **"Gestión de Base de Datos"**
3. Haz clic para acceder a la página

### Crear un Backup

1. En la sección **"Crear backup"**:
   - Ingresa la ruta completa donde deseas guardar el backup
   - Ejemplo: `C:\Backups\Hirebot\Hirebot_Backup_20250104_153000.bak`
2. Haz clic en **"Crear backup"**
3. El proceso puede tardar varios minutos dependiendo del tamaño de la base de datos
4. Una vez completado, verás un mensaje de éxito

### Restaurar un Backup

**⚠️ ADVERTENCIA**: Restaurar un backup reemplazará TODOS los datos actuales. Esta acción NO se puede deshacer.

1. En la sección **"Restaurar backup"**:
   - Ingresa la ruta completa del archivo .bak que deseas restaurar
   - Ejemplo: `C:\Backups\Hirebot\Hirebot_Backup_20250104_153000.bak`
2. Haz clic en **"Restaurar backup"**
3. Confirma la acción en el diálogo de confirmación
4. El proceso cerrará todas las conexiones activas a la base de datos
5. Una vez completado, reinicia la aplicación

### Listar Backups Disponibles

1. En la sección **"Backups disponibles"**:
   - Ingresa el directorio donde se encuentran los backups
   - Ejemplo: `C:\Backups\Hirebot`
2. Haz clic en **"Listar backups"**
3. Se mostrarán todos los archivos .bak encontrados
4. Puedes copiar la ruta de cualquier backup al portapapeles haciendo clic en **"Copiar ruta"**

## Arquitectura

La funcionalidad sigue el patrón de 5 capas del proyecto:

```
UI (AdminDatabase.aspx)
  ↓
Security (DatabaseBackupSecurity.cs)
  ↓
BLL (DatabaseBackupBLL.cs)
  ↓
DAL (DatabaseBackupDAL.cs)
  ↓
SQL Server [master] (Stored Procedures)
```

### Archivos Creados

**Stored Procedures:**
- `Database/AdminDatabaseStoredProcedures.sql`

**Abstractions:**
- `ABSTRACTIONS/DatabaseBackup.cs`

**DAL:**
- `DAL/DatabaseBackupDAL.cs`

**BLL:**
- `BLL/DatabaseBackupBLL.cs`

**Security:**
- `security/DatabaseBackupSecurity.cs`

**UI:**
- `Hirebot-TFI/AdminDatabase.aspx`
- `Hirebot-TFI/AdminDatabase.aspx.cs`
- `Hirebot-TFI/AdminDatabase.aspx.designer.cs`

**Modificaciones:**
- `Hirebot-TFI/Admin.master` - Agregado enlace de navegación

## Seguridad

- Solo usuarios con rol **"Administrador"** pueden acceder a esta funcionalidad
- Todas las operaciones requieren autenticación
- Los stored procedures validan entradas y manejan errores apropiadamente
- Durante la restauración, todas las conexiones activas se cierran automáticamente

## Notas Importantes

1. **Backup Path**: Debe ser una ruta completa y válida en el servidor SQL Server
2. **Permisos**: El usuario SQL debe tener permisos de BACKUP DATABASE y RESTORE DATABASE
3. **Espacio en Disco**: Asegúrate de tener suficiente espacio para los backups
4. **Timeout**: Los comandos tienen timeouts extendidos (5 minutos para backup, 10 minutos para restore)
5. **Concurrencia**: Durante la restauración, la base de datos se pone en modo SINGLE_USER temporalmente

## Troubleshooting

### Error: "No tiene permisos para realizar esta operación"
- Verifica que el usuario está logueado con rol "Administrador"
- Revisa los permisos de ejecución en los stored procedures

### Error: "Cannot open backup device"
- Verifica que la ruta del archivo es accesible desde el servidor SQL Server
- Asegúrate de que la cuenta de servicio de SQL Server tiene permisos en el directorio

### Error: "Database is in use"
- Cierra todas las conexiones activas a la base de datos
- Espera unos segundos y vuelve a intentar

### Error al listar backups
- Verifica que el directorio existe
- Asegúrate de que la cuenta de SQL Server puede acceder al directorio
- Usa rutas locales del servidor SQL (no rutas UNC sin configurar)

## Recomendaciones

1. **Backups Automáticos**: Configura SQL Server Agent para crear backups programados
2. **Retención**: Implementa una política de retención de backups
3. **Pruebas**: Prueba regularmente el proceso de restauración
4. **Monitoreo**: Revisa los logs de la aplicación después de operaciones de backup/restore
5. **Notificaciones**: Considera agregar notificaciones por email cuando se crean o restauran backups
