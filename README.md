# docker_python

Installation de Python3 et des plugins intéressants

La configuration de Vim et des plugins de Vimified https://github.com/zaiste/vimified

# Démarrage

Pour construire l'image et le conteneur, on tape:

```
cd /..../docker_python/
docker-compose build
docker-compose up -d

ssh -X ubuntu@localhost
ubuntu@localhost's password:
```

Le mot de passe est *ubuntu*

Le paramètre "-X" permet de créer un pont X11 pour l'affichage de Atom sur le
poste hôte bien que Atom s'exécute dans le conteneur.


