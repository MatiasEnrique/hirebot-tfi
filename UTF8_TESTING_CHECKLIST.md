# UTF-8 Encoding - Testing Checklist

## Pre-Test Setup
- [ ] Build solution successfully
- [ ] Clear browser cache
- [ ] Run application in Debug mode (F5)

---

## Homepage Testing (Default.aspx)

### Spanish Text to Verify:
- [ ] "¡Bienvenido a Hirebot-TFI!" displays correctly
- [ ] "Español" in language selector displays correctly
- [ ] Navigation: "Catálogo de Productos" displays correctly
- [ ] Navigation: "Iniciar Sesión" displays correctly
- [ ] Footer: "Contáctenos" displays correctly

### Expected Results:
✅ All Spanish characters (á, é, í, ó, ú, ñ, ¿, ¡) display correctly
❌ NO garbled text like "Ã±" or "Ã³"

---

## Sign In Page Testing (SignIn.aspx)

### Spanish Text to Verify:
- [ ] "Bienvenido de nuevo" displays correctly
- [ ] "Inicia sesión en tu cuenta" displays correctly
- [ ] Label: "Usuario o Correo" displays correctly
- [ ] Label: "Contraseña" displays correctly
- [ ] Button: "Iniciar Sesión" displays correctly
- [ ] Link: "¿Olvidaste tu contraseña?" displays correctly
- [ ] Text: "¿No tienes una cuenta?" displays correctly

### Expected Results:
✅ "Contraseña" appears correctly (NOT "ContraseÃ±a")
✅ "¿Olvidaste tu contraseña?" appears correctly (NOT "Â¿Olvidaste tu contraseÃ±a?")

---

## Catalog Page Testing (Catalog.aspx)

### Spanish Text to Verify:
- [ ] Page title: "Catálogo de Productos" displays correctly
- [ ] Navigation menu items display correctly
- [ ] Product descriptions with Spanish text display correctly
- [ ] Search placeholder text displays correctly

### Expected Results:
✅ "Catálogo" appears correctly (NOT "CatÃ¡logo")

---

## Dashboard Testing (Dashboard.aspx)

### Spanish Text to Verify:
- [ ] "Panel de Control" displays correctly
- [ ] "Organizaciones" displays correctly
- [ ] "Suscripciones" displays correctly
- [ ] Any Spanish content in dashboard cards

### Expected Results:
✅ "Sesión" appears correctly (NOT "SesiÃ³n")
✅ Navigation items display correctly

---

## Admin Pages Testing

### Pages to Check:
- [ ] AdminDashboard.aspx
- [ ] AdminCatalog.aspx
- [ ] AdminRoles.aspx
- [ ] AdminNews.aspx
- [ ] AdminSurveys.aspx

### Spanish Text to Verify:
- [ ] "Gestión de..." items display correctly
- [ ] "Administración" displays correctly
- [ ] Form labels with Spanish text
- [ ] Button text with Spanish characters

### Expected Results:
✅ All admin interface Spanish text displays correctly

---

## Language Switching Testing

### Test Steps:
1. [ ] Start with Spanish (default)
2. [ ] Verify Spanish characters display correctly
3. [ ] Switch to English using language selector
4. [ ] Verify English text displays correctly
5. [ ] Switch back to Spanish
6. [ ] Verify Spanish characters still display correctly

### Expected Results:
✅ Language switching works without encoding issues
✅ No character corruption after switching languages

---

## Browser Console Testing

### Check in Developer Tools:
- [ ] Open browser Developer Tools (F12)
- [ ] Go to Console tab
- [ ] Verify no encoding warnings or errors
- [ ] Go to Network tab
- [ ] Click on any page request
- [ ] Check Response Headers
  - [ ] Content-Type should include: `charset=utf-8`

### Expected Console Output:
✅ No errors related to character encoding
✅ Response headers include `charset=utf-8`

---

## User Controls Testing

### Controls to Verify:
- [ ] LanguageSelector.ascx displays correctly
- [ ] ToastNotification.ascx messages display correctly
- [ ] PaginatedDataTable.ascx displays correctly
- [ ] Any user control with Spanish text

### Expected Results:
✅ All user controls render Spanish text correctly

---

## Cross-Browser Testing

### Browsers to Test:
- [ ] Google Chrome (latest)
- [ ] Microsoft Edge (latest)
- [ ] Firefox (latest)
- [ ] Safari (if available)

### Expected Results:
✅ Spanish characters display correctly in all browsers

---

## Mobile Responsive Testing

### Devices/Sizes to Test:
- [ ] Mobile (320px - 767px)
- [ ] Tablet (768px - 1023px)
- [ ] Desktop (1024px+)

### Expected Results:
✅ Spanish characters display correctly on all screen sizes
✅ No encoding issues in responsive layouts

---

## Common Issues to Check

### If Spanish characters still display incorrectly:

1. **Check File Encoding:**
   - Open file in text editor
   - Verify saved as UTF-8 (not UTF-8 with BOM, not ANSI)

2. **Check Browser:**
   - Clear browser cache completely
   - Hard refresh (Ctrl+F5 or Cmd+Shift+R)

3. **Check IIS/Server:**
   - Verify IIS has UTF-8 configured (if deployed)
   - Check Response.Charset not being overridden in code

4. **Check Database:**
   - If content comes from database, verify database column collation is UTF-8 compatible

---

## Test Results Template

Date: _______________
Tester: _______________

| Page/Component | Status | Notes |
|----------------|--------|-------|
| Default.aspx | ⬜ Pass ⬜ Fail | |
| SignIn.aspx | ⬜ Pass ⬜ Fail | |
| Catalog.aspx | ⬜ Pass ⬜ Fail | |
| Dashboard.aspx | ⬜ Pass ⬜ Fail | |
| Admin Pages | ⬜ Pass ⬜ Fail | |
| Language Switching | ⬜ Pass ⬜ Fail | |
| User Controls | ⬜ Pass ⬜ Fail | |
| Browser Console | ⬜ Pass ⬜ Fail | |

Overall Result: ⬜ PASS ⬜ FAIL

Comments:
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## Sign-Off

- [ ] All Spanish characters display correctly across all tested pages
- [ ] No garbled text observed
- [ ] Browser console shows no encoding errors
- [ ] Response headers include UTF-8 charset
- [ ] Language switching works correctly
- [ ] Cross-browser testing passed
- [ ] Mobile responsive testing passed

**Fix Status:** ⬜ APPROVED ⬜ NEEDS REVISION

Approved By: _______________
Date: _______________
