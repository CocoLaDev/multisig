// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Multisig.sol";

contract MultisigDeployScript is Script {
    Multisig public wallet;
    address[] public signers;

    function run() external {
        address signer1 = vm.envAddress("SIGNER1");
        address signer2 = vm.envAddress("SIGNER2");

        require(signer1 != address(0), "SIGNER1 cannot be zero address");
        require(signer2 != address(0), "SIGNER2 cannot be zero address");
        require(signer1 != signer2, "SIGNER1 and SIGNER2 must be different");

        vm.startBroadcast();

        signers = [signer1, signer2];

        wallet = new Multisig(signers);

        vm.stopBroadcast();

        console.log("WalletMultisig deployed at:", address(wallet));
    }
}