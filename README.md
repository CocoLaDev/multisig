# Multisig Wallet

## Description

Le contrat `Multisig` est un portefeuille multi-signatures qui permet à plusieurs administrateurs de gérer des transactions de manière sécurisée. Ce type de contrat est particulièrement utile pour les organisations ou les groupes qui souhaitent partager le contrôle des fonds et des transactions, en nécessitant plusieurs signatures pour valider une action.

## Fonctionnalités

- **Ajout et suppression d'administrateurs** : Les administrateurs peuvent être ajoutés ou supprimés par les signataires existants.
- **Soumission de transactions** : Les signataires peuvent soumettre des transactions à exécuter.
- **Confirmation et révocation de transactions** : Les signataires peuvent confirmer ou révoquer des transactions soumises.
- **Exécution de transactions** : Une fois qu'une transaction est confirmée par le nombre requis de signataires, elle peut être exécutée.
- **Récupération des signataires et des transactions** : Les signataires peuvent récupérer la liste des signataires et des transactions effectuées.

## Exemples de fonctions

- **Ajouter un administrateur** :
  ```solidity
  multisig.addAdmin(newAdminAddress);
  ```

- **Soumettre une transaction** :
  ```solidity
  multisig.submitTransaction(toAddress, value, data);
  ```

- **Confirmer une transaction** :
  ```solidity
  multisig.confirmTransaction(nonce);
  ```

## Contribuer

Les contributions sont les bienvenues ! Si vous souhaitez améliorer ce projet, veuillez suivre ces étapes :

1. Forkez le projet.
2. Créez une nouvelle branche (`git checkout -b feature/YourFeature`).
3. Apportez vos modifications et validez-les (`git commit -m 'Add some feature'`).
4. Poussez votre branche (`git push origin feature/YourFeature`).
5. Ouvrez une Pull Request.

## License

Ce projet est sous licence UNLICENSED. Veuillez consulter le fichier `LICENSE` pour plus de détails.