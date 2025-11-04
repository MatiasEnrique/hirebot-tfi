# UTF-8 Encoding Quick Reference

## For New Pages/Controls

### New ASPX Page
```asp
<%@ Page
    Title="Page Title"
    Language="C#"
    MasterPageFile="~/Public.master"
    AutoEventWireup="true"
    CodeBehind="NewPage.aspx.cs"
    Inherits="Namespace.NewPage"
    ResponseEncoding="utf-8" %>
```

### New Master Page
```asp
<%@ Master
    Language="C#"
    AutoEventWireup="true"
    CodeBehind="NewMaster.master.cs"
    Inherits="Namespace.NewMaster"
    ResponseEncoding="utf-8" %>
```

### New User Control
```asp
<%@ Control
    Language="C#"
    AutoEventWireup="true"
    CodeBehind="NewControl.ascx.cs"
    Inherits="Namespace.NewControl"
    ResponseEncoding="utf-8" %>
```

## Key Points

1. **Always include** `ResponseEncoding="utf-8"` in the page/control directive
2. **Save files** with UTF-8 encoding (not UTF-8 with BOM)
3. **Test with Spanish** text to verify encoding works
4. **web.config** already configured globally - don't modify

## Common Spanish Characters to Test

- á é í ó ú (lowercase accents)
- Á É Í Ó Ú (uppercase accents)
- ñ Ñ (eñe)
- ¿ ¡ (inverted punctuation)
- ü Ü (dieresis)

## If Issues Persist

1. Check browser network tab: Content-Type should include `charset=utf-8`
2. Verify file is saved as UTF-8 (not ANSI or UTF-8 with BOM)
3. Check Response.Charset in code-behind is not overriding
4. Ensure no BOM (Byte Order Mark) in file
