// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Multisig {
    enum TxType { None, AddAdmin, RemoveAdmin, Transaction }
    enum TxStatus { None, Created, Confirmed, Revoked, Executed }

    address[] private _signers;
    uint8 private _minSigners;
    uint8 private _confimations;

    struct Tx {
        TxType txType;
        address[] validated;
        address[] revoked;
        TxStatus status;
        address to;
        uint256 value;
        bytes data;
    }

    mapping(uint16 => Tx) private _transactions;
    uint16 private _nonce;

    constructor(address[] memory signers){
        _signers = signers;
        _confimations = 2;
    }

    modifier onlySigner(){
        uint size = _signers.length;
        bool isSigner;
        for(uint i = 0; i < size; i+=1){
            if(_signers[i] == msg.sender){
                isSigner = true;
                break;
            }
        }
        require(isSigner, "Only signers can call this function");
        _;
    }

    /**
     * @dev Ajoute un nouvel administrateur.
     * @param newAdmin L'adresse du nouvel administrateur à ajouter.
     */
    function addAdmin(address newAdmin) public onlySigner {
        bytes memory adminAddress = abi.encodePacked(newAdmin);
        _transactions[++_nonce] = Tx(TxType.AddAdmin, new address[](0), new address[](0), TxStatus.Created, address(0), 0, adminAddress);
    }

    /**
     * @dev Supprime un administrateur existant.
     * @param admin L'adresse de l'administrateur à supprimer.
     */
    function removeAdmin(address admin) public onlySigner {
        bytes memory adminAddress = abi.encodePacked(admin);
        _transactions[++_nonce] = Tx(TxType.RemoveAdmin, new address[](0), new address[](0), TxStatus.Created, address(0), 0, adminAddress);
    }

    /**
     * @dev Soumet une nouvelle transaction.
     * @param to L'adresse à laquelle envoyer des fonds.
     * @param value Le montant à envoyer.
     * @param data Les données à envoyer avec la transaction.
     */
    function submitTransaction(address to, uint value, bytes memory data) public onlySigner {
        _transactions[++_nonce] = Tx(TxType.Transaction, new address[](0), new address[](0), TxStatus.Created, to, value, data);
    }

    /**
     * @dev Confirme une transaction soumise.
     * @param nonce Le nonce de la transaction à confirmer.
     */
    function confirmTransaction(uint16 nonce) public onlySigner {
        require(_transactions[nonce].status == TxStatus.Created, "Transaction already confirmed or revoked");
        _transactions[nonce].validated.push(msg.sender);
        if(_transactions[nonce].validated.length == _confimations){
            _transactions[nonce].status = TxStatus.Confirmed;
        }
    }

    /**
     * @dev Révoque une transaction soumise.
     * @param nonce Le nonce de la transaction à révoquer.
     */
    function revokeTransaction(uint16 nonce) public onlySigner {
        require(_transactions[nonce].status == TxStatus.Created, "Transaction already confirmed or revoked");
        _transactions[nonce].revoked.push(msg.sender);
        if(_transactions[nonce].revoked.length == _confimations){
            _transactions[nonce].status = TxStatus.Revoked;
        }
    }

    /**
     * @dev Exécute une transaction confirmée.
     * @param nonce Le nonce de la transaction à exécuter.
     */
    function executeTransaction(uint16 nonce) public onlySigner {
        Tx storage transaction = _transactions[nonce];
        require(transaction.status == TxStatus.Confirmed, "Transaction not confirmed");
        if(transaction.txType == TxType.Transaction){
            transaction.status = TxStatus.Executed;
            (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
            require(success, "Transaction failed");
        }
        if(transaction.txType == TxType.AddAdmin){
            _signers.push(address(uint160(uint256(keccak256(transaction.data)))));
        }
        if(transaction.txType == TxType.RemoveAdmin){
            uint size = _signers.length;
            for(uint i = 0; i < size; i+=1){
                if(_signers[i] == address(uint160(uint256(keccak256(transaction.data))))){
                    _signers[i] = _signers[size-1];
                    _signers.pop();
                    break;
                }
            }
        }
    }

    /**
     * @dev Récupère la liste des signataires.
     * @return Un tableau d'adresses des signataires.
     */
    function getSigners() public view returns(address[] memory){
        return _signers;
    }

    /**
     * @dev Récupère toutes les transactions.
     * @return Un tableau de transactions.
     */
    function getTransactions() public view returns(Tx[] memory){
        Tx[] memory transactions = new Tx[](_nonce);
        for(uint i = 0; i < _nonce; i+=1){
            transactions[i] = _transactions[uint16(i)];
        }
        return transactions;
    }

    /**
     * @dev Récupère une transaction spécifique par son nonce.
     * @param nonce Le nonce de la transaction à récupérer.
     * @return La transaction correspondante.
     */
    function getTransaction(uint16 nonce) public view returns(Tx memory){
        return _transactions[nonce];
    }

    /**
     * @dev Récupère le nonce actuel.
     * @return Le nonce actuel.
     */
    function getNonce() public view returns(uint16){
        return _nonce;
    }

    /**
     * @dev Récupère le nombre minimum de signataires requis.
     * @return Le nombre minimum de signataires.
     */
    function getMinSigners() public view returns(uint8){
        return _minSigners;
    }

    /**
     * @dev Récupère le nombre de confirmations requis.
     * @return Le nombre de confirmations.
     */
    function getConfimations() public view returns(uint8){
        return _confimations;
    }
}