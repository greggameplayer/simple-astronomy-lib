---
## Membres du groupe :
- Grégoire Hage
- Victor Marit
- Jad Daouk
- David Cherik
- Calvin Djafari
---
## Description de ce qui a été fait :
Nous avons créé une CI/CD Jenkins (qui est exécuté lors de push de commits sur le git sur un jenkins hébergé sur un cluster kubernetes) en se basant sur le projet simple-astronomy-lib qui effectue les étapes suivantes :
- Création d'un pod kubernetes avec un conteneur Maven et un conteneur Docker in Docker
- Récupération du git du projet
- Compilation du projet
- Exécution des tests du projet
- Exécution d'une analyse de code statique avec checkStyle et spotBugs
- Exécution d'une analyse sonar publié sur un sonarqube hébergé
- Publication des artefacts sur un nexus hébergé
- Compilation d'une image docker multi-architectures (amd64, arm64) et publication sur un registry docker hébergé
- Publication des tests unitaires et statiques, du code coverage et des artefacts sur jenkins
- Effacement du workspace

La seule difficulté rencontrée a été la compilation en image docker car dû au fait que le jenkins hébergé se situe sur un cluster kubernetes
jenkins n'a pas accés à un exécutable docker (car depuis de nombreuses versions maintenant kubernetes est basé directement sur containerd) du coup il n'est pas possible d'utiliser le docker cli directement pour compiler,
il faut donc passer par un conteneur docker in docker qui va permettre de compiler l'image docker.
