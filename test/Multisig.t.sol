// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Multisig.sol";


contract MultisigTest is Test {
    Multisig public multisig;
    address[] public signers;

    function setUp() public {
        signers = [address(0x1), address(0x2), address(0x3)];
        multisig = new Multisig(signers);
    }

    function test_ConfirmTransaction() public {
        vm.prank(signers[0]);
        multisig.submitTransaction(address(0x4), 1 ether, "0x");

        vm.prank(signers[0]);
        multisig.confirmTransaction(1);

        vm.prank(signers[1]);
        multisig.confirmTransaction(1);

        assertEq(uint(multisig.getTransaction(1).status), uint(Multisig.TxStatus.Confirmed));
    }

    function test_RevokeTransaction() public {
        vm.prank(signers[0]);
        multisig.submitTransaction(address(0x4), 1 ether, "0x");

        vm.prank(signers[0]);
        multisig.revokeTransaction(1);

        vm.prank(signers[1]);
        multisig.revokeTransaction(1);

        assertEq(uint(multisig.getTransaction(1).status), uint(Multisig.TxStatus.Revoked));
    }

    function test_ExecuteTransaction() public {
        vm.prank(signers[0]);
        multisig.submitTransaction(address(0x4), 0 ether, "0x");

        vm.prank(signers[0]);
        multisig.confirmTransaction(1);

        vm.prank(signers[1]);
        multisig.confirmTransaction(1);

        vm.prank(signers[0]);
        multisig.executeTransaction(1);

        assertEq(uint(multisig.getTransaction(1).status), uint(Multisig.TxStatus.Executed));
    }

    

    function test_AddAdmin() public {
        vm.prank(signers[0]);
        multisig.addAdmin(address(0x4));

        vm.prank(signers[0]);
        multisig.confirmTransaction(1);

        vm.prank(signers[1]);
        multisig.confirmTransaction(1);

        vm.prank(signers[0]);
        multisig.executeTransaction(1);

        assertEq(uint(multisig.getTransaction(1).txType), uint(Multisig.TxType.AddAdmin));
    }

    function test_RemoveAdmin() public {
        vm.prank(signers[0]);
        multisig.removeAdmin(address(0x1));

        vm.prank(signers[0]);
        multisig.confirmTransaction(1);

        vm.prank(signers[1]);
        multisig.confirmTransaction(1);

        vm.prank(signers[0]);
        multisig.executeTransaction(1);

        assertEq(uint(multisig.getTransaction(1).txType), uint(Multisig.TxType.RemoveAdmin));
    }

    function test_RevokeAfterPartialConfirmation() public {
        vm.prank(signers[0]);
        multisig.submitTransaction(address(0x4), 1 ether, "0x");

        vm.prank(signers[0]);
        multisig.confirmTransaction(1);

        vm.prank(signers[1]);
        multisig.revokeTransaction(1);

        vm.prank(signers[2]);
        multisig.revokeTransaction(1);

        assertEq(uint(multisig.getTransaction(1).status), uint(Multisig.TxStatus.Revoked));
    }

    function test_ExecuteRevokedTransactionFails() public {
        vm.prank(signers[0]);
        multisig.submitTransaction(address(0x4), 1 ether, "0x");

        vm.prank(signers[0]);
        multisig.confirmTransaction(1);
        
        vm.prank(signers[1]);
        multisig.revokeTransaction(1);

        vm.prank(signers[0]);
        vm.expectRevert("Transaction not confirmed");
        multisig.executeTransaction(1);
    }

    function test_ExecuteUnconfirmedTransactionFails() public {
        vm.prank(signers[0]);
        multisig.submitTransaction(address(0x4), 1 ether, "0x");

        vm.prank(signers[0]);
        vm.expectRevert("Transaction not confirmed");
        multisig.executeTransaction(1);
    }

    function test_GetSigners() public view {
        address[] memory currentSigners = multisig.getSigners();
        for (uint i = 0; i < currentSigners.length; i++) {
            assertEq(currentSigners[i], signers[i]);
        }
    }

    function test_GetMinSigners() public view {
        assertEq(multisig.getMinSigners(), 0);
    }

    function test_GetConfimations() public view {
        assertEq(multisig.getConfimations(), 2);
    }

    function test_OnlySignerModifier() public {
        address nonSigner = address(0x5);
        vm.prank(nonSigner);
        vm.expectRevert("Only signers can call this function");
        multisig.addAdmin(address(0x6));
    }

    function test_GetTransactions() public {
        vm.prank(signers[0]);
        multisig.submitTransaction(address(0x4), 1 ether, "0x");
        
        assertEq(multisig.getNonce(), 1);

        vm.prank(signers[0]);
        multisig.confirmTransaction(1);
        vm.prank(signers[1]);
        multisig.confirmTransaction(1);

        Multisig.Tx[] memory transactions = multisig.getTransactions();
        assertEq(transactions.length, 1);
        assertEq(uint(multisig.getTransaction(1).status), uint(Multisig.TxStatus.Confirmed));
    }

    function test_GetNonce() public {
        assertEq(multisig.getNonce(), 0);
        vm.prank(signers[0]);
        multisig.submitTransaction(address(0x4), 1 ether, "0x");
        assertEq(multisig.getNonce(), 1);
    }

    function test_ExecuteTransactionByNonSignerFails() public {
        vm.prank(signers[0]);
        multisig.submitTransaction(address(0x4), 0 ether, "0x");

        vm.prank(signers[0]);
        multisig.confirmTransaction(1);
        vm.prank(signers[1]);
        multisig.confirmTransaction(1);

        address nonSigner = address(0x5);
        vm.prank(nonSigner);
        vm.expectRevert("Only signers can call this function");
        multisig.executeTransaction(1);
    }

}