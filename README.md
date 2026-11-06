# Calcula — app iOS (clon con Capacitor)

Clon para iOS de la app web de gastos **Calcula**, del repositorio
original [`legaoc/psnlgastos`](https://github.com/legaoc/psnlgastos).
**El repositorio original queda intacto**: este proyecto es una copia
independiente que empaqueta la web con Capacitor para generar un IPA.

## Cómo funciona

- La web original (`www/index.html`, Firebase Auth con email y contraseña
  + Firestore por CDN, PWA con `sw.js`) se sirve localmente dentro de la
  app con Capacitor (`webDir: www`).
- El proyecto iOS nativo está en `ios/` (generado con
  `npx cap add ios` y sincronizado con `npx cap sync ios`).
- El workflow `.github/workflows/build-ipa.yml` compila en GitHub Actions
  (macOS) y sube el artefacto `Calcula-IPA` con el archivo `Calcula.ipa`.

## Imágenes reemplazadas por SVG en línea

Las imágenes PNG originales (`calcula-logo.png`, `calcula-wordmark.png`,
`apple-touch-icon.png`, `favicon.png`, `favicon.ico`) son binarias y no
se copiaron a este proyecto. Sus referencias en `www/index.html` se
reemplazaron por data URIs SVG en línea (texto "Calcula" en blanco sobre
fondo `#050505`). Las metas `og:image` absolutas a
`legaoc.github.io` se dejaron tal cual (solo son metadatos).

### Cómo restaurar las PNG originales

1. Sube los archivos `calcula-logo.png`, `calcula-wordmark.png`,
   `apple-touch-icon.png` y `favicon.png` a la carpeta `www/` (por
   ejemplo, desde la web de GitHub).
2. En `www/index.html`, reemplaza cada data URI `data:image/svg+xml,...`
   por el nombre del archivo original que corresponde:
   - En el SVG del splash (`<image href>` y `xlink:href`) y en los
     `<link>`/`<img>` de icono: vuelve a `calcula-logo.png` o
     `apple-touch-icon.png` según el caso.
   - En el `<img class="brand-wordmark">` y en
     `loadShareImage("...")`: vuelve a `calcula-wordmark.png`.
   - En el `<link rel="icon">`: vuelve a `favicon.png`.
3. Vuelve a agregar el array `"icons"` en `www/manifest.json` si quieres
   los iconos PWA originales.
4. Corre `npx cap sync ios` para copiar los cambios a la app nativa.

## Instalación en iPhone

El IPA se compila **SIN firma** (`CODE_SIGNING_ALLOWED=NO`), así que
no se puede instalar directamente en el iPhone. Para instalarlo hay
que firmarlo con tu propio Apple ID, por ejemplo con
**AltStore** o **Sideloadly** (con cuenta gratuita la firma dura 7 días
y hay que renovarla).

## Icono y splash de la app

El icono y la pantalla de inicio de la app nativa quedaron sin imagen
(los PNG de plantilla de Capacitor no se incluyeron porque son binarios).
La app compila igual, solo se verá sin icono propio. Para poner el icono
real de Calcula, sube tus PNG a `ios/App/App/Assets.xcassets/AppIcon.appiconset/`
(icono 1024x1024) y a `ios/App/App/Assets.xcassets/Splash.imageset/`
(splash) por la web de GitHub y agrega sus nombres en los `Contents.json`
de esas carpetas.

## Requisitos de la app

La app **necesita internet**: los datos viven en Firebase (Auth y
Firestore cargados por CDN) y el inicio de sesión es con email y
contraseña. Sin conexión no se puede entrar ni sincronizar gastos.

## Desarrollo local

```bash
npm install
npx cap sync ios
```

Abrir `ios/App/App.xcworkspace` en Xcode para compilar en un dispositivo.
