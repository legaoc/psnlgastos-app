const CACHE = "calcula-offline-v4";

const ASSETS = [
  "./",
  "./index.html",
  "./manifest.json",
  "./calcula-logo.png",
  "./calcula-wordmark.png",
  "./apple-touch-icon.png",
  "./favicon.png",
  "./favicon.ico",
  "./icon-192.png",
  "./icon-512.png"
];

const FIREBASE_ASSETS = [
  "https://www.gstatic.com/firebasejs/11.10.0/firebase-app.js",
  "https://www.gstatic.com/firebasejs/11.10.0/firebase-firestore.js",
  "https://www.gstatic.com/firebasejs/11.10.0/firebase-auth.js",
  "https://cdn.jsdelivr.net/npm/skeleton-elements@4.0.1/css/skeleton-elements.min.css"
];


function isFirestoreRequest(url){

  return url.hostname.includes("googleapis.com") ||
    url.hostname.includes("firestore.googleapis.com") ||
    url.hostname.includes("google.com") &&
      url.pathname.includes("/v1/");

}


function isAppPage(url){

  const path = url.pathname;

  return path.endsWith("/") ||
    path.endsWith("/index.html") ||
    path.endsWith("/psnlgastos") ||
    path.endsWith("/psnlgastos/");

}


self.addEventListener("install", event=>{

  event.waitUntil(
    caches.open(CACHE)
      .then(cache=>
        cache.addAll([...ASSETS, ...FIREBASE_ASSETS])
          .catch(()=>cache.addAll(ASSETS))
      )
      .then(()=>self.skipWaiting())
  );

});


self.addEventListener("activate", event=>{

  event.waitUntil(
    caches.keys()
      .then(keys=>
        Promise.all(
          keys
            .filter(key=>key!==CACHE)
            .map(key=>caches.delete(key))
        )
      )
      .then(()=>self.clients.claim())
  );

});


self.addEventListener("fetch", event=>{

  const request = event.request;

  if(request.method!=="GET") return;

  const url = new URL(request.url);

  if(url.protocol!=="http:" && url.protocol!=="https:") return;

  if(isFirestoreRequest(url)) return;

  if(isAppPage(url)){
    event.respondWith(networkFirst(request));
    return;
  }

  event.respondWith(cacheFirst(request));

});


async function networkFirst(request){

  try{

    const fresh = await fetch(request);
    const cache = await caches.open(CACHE);
    cache.put("./index.html", fresh.clone());
    return fresh;

  }
  catch{

    return await caches.match("./index.html") ||
      await caches.match("./") ||
      new Response("Sin conexión", {
        status:503,
        headers:{ "Content-Type":"text/plain; charset=utf-8" }
      });

  }

}


async function cacheFirst(request){

  const cached = await caches.match(request);

  if(cached) return cached;

  try{

    const fresh = await fetch(request);
    const cache = await caches.open(CACHE);
    cache.put(request, fresh.clone());
    return fresh;

  }
  catch{

    return new Response("", { status:504 });

  }

}


self.addEventListener("notificationclick", event=>{

  event.notification.close();

  event.waitUntil(
    self.clients.matchAll({ type:"window", includeUncontrolled:true })
      .then(windows=>{
        const open = windows.find(client=>client.url && "focus" in client);
        if(open) return open.focus();
        if(self.clients.openWindow) return self.clients.openWindow("./");
      })
  );

});
