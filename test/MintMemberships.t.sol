// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/Vm.sol";
import {dAgoraMemberships} from "../src/dAgoraMemberships.sol";
import {TestDAI} from "../src/mock/testDAI.sol";
import {Token} from "../src/mock/token.sol";
import {ChainLink} from "../src/mock/linkToken.sol";
import {MockOperator} from "../src/mock/mockOperator.sol";
import {SigUtils} from "../src/mock/sigUtils.sol";

contract MintMembershipsTest is Test {
    address dAgoraTreasury = address(0x1337);
    // address signer = address(0x133702);
    address alice = address(0x133703);
    address public bob;
    address carol = address(0x133704);

    
    uint256 public bobKeys = 0xB0B;

    dAgoraMemberships dAgora;
    ChainLink link;
    MockOperator operator;
    TestDAI dai;
    Token token;
    SigUtils sigUtils;
    

    uint256 oracleFee = 1 * 10 ** 17;
    uint256 ecceliaePrice = 0;
    uint256 dagorianPrice = 50 * 10 ** 18;
    uint256 hoplitePrice = 80 * 10 ** 18;
    uint256 periclesiaPrice = 1000 * 10 ** 18;
    uint256 monthlyPrice = 5 * 10 ** 18;
    uint256 _deadline = block.timestamp + 600;

    bytes32 public jobId =
        0xf7f77ea15719ea30bd2a584962ab273b1116f0e70fe80bbb0b30557d0addb7f3;

    function setUp() public {
        link = new ChainLink();
        vm.startPrank(dAgoraTreasury);
        dai = new TestDAI();
        token = new Token();
        bob = vm.addr(bobKeys);

        link._mint();
        operator = new MockOperator(address(link));

        sigUtils = new SigUtils(dai.DOMAIN_SEPARATOR());

        link.transfer(address(operator), 100);
        dAgora = new dAgoraMemberships(
                'ipfs://BaseURIOrCID/',
                address(dai),
                address(dAgoraTreasury),
                '3433',
                3950,
                address(link),
                address(operator),
                jobId,
                oracleFee
            );

        dAgora.togglePaused();
        vm.stopPrank();
        

        vm.startPrank(bob);
        dai._mint();
        vm.stopPrank();
    }

    // function testMintFreeClaim() public {
    //     vm.startPrank(bob);

    //         dAgora.mintFreeClaim();
    //     vm.stopPrank();
    // }


    function testMint_dAgorian() public {
        vm.startPrank(bob);
        uint256 monthlyCost = (monthlyPrice * 1);
        uint256 price = monthlyCost + dagorianPrice;
       
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintdAgoraMembership(
            1, 
            dAgoraMemberships.Membership(1), 
            _deadline, 
            v, 
            r, 
            s
        );

        console.log(dAgora.expires(1));

        assertEq(dAgora.totalSupply(), 1);
        assertEq(dAgora.balanceOf(address(bob)), 1);
        assertEq(dAgora.checkTokenTier(1), 1);
        assertEq(dai.balanceOf(address(dAgoraTreasury)), price);
        vm.stopPrank();
    }


    function testMint_Hoptile() public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + hoplitePrice;
 
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit); 

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintdAgoraMembership(
            1, 
            dAgoraMemberships.Membership(2), 
            _deadline, 
            v, 
            r, 
            s
        );

        assertEq(dAgora.totalSupply(), 1);
        assertEq(dAgora.balanceOf(address(bob)), 1);
        assertEq(dAgora.checkTokenTier(1), 2);
        assertEq(dai.balanceOf(address(dAgoraTreasury)), price);
        vm.stopPrank();
    }

    function testMint_Periclesia() public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + periclesiaPrice;
        
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintdAgoraMembership(
            1, 
            dAgoraMemberships.Membership(3), 
            _deadline, 
            v, 
            r, 
            s
        );

        assertEq(dAgora.totalSupply(), 1);
        assertEq(dAgora.balanceOf(address(bob)), 1);
        assertEq(dAgora.checkTokenTier(1), 3);
        assertEq(dai.balanceOf(address(dAgoraTreasury)), price);
        vm.stopPrank();
    }

    function testFullTokenFlow() public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + dagorianPrice;
        
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintdAgoraMembership(
            1, 
            dAgoraMemberships.Membership(1), 
            _deadline, 
            v, 
            r, 
            s
        );

        assertEq(dAgora.totalSupply(), 1);
        assertEq(dAgora.balanceOf(address(bob)), 1);
        assertEq(dAgora.checkTokenTier(1), 1);
        assertEq(dai.balanceOf(address(dAgoraTreasury)), price);

        uint256 updatedPriceHop = hoplitePrice - dagorianPrice;

        SigUtils.Permit memory upgradePermit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: updatedPriceHop,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 upgradeDigest = sigUtils.getTypedDataHash(upgradePermit);

        (uint8 upgradeV, bytes32 upgradeR, bytes32 upgradeS) = vm.sign(bobKeys, upgradeDigest);

        dAgora.upgradeMemebership(
            1,
            dAgoraMemberships.Membership(2),
            _deadline,
            upgradeV,
            upgradeR,
            upgradeS
        );

        assertEq(dAgora.checkTokenTier(1), 2);

        uint256 updatedPricePer = periclesiaPrice - (hoplitePrice + dagorianPrice);

        SigUtils.Permit memory upgradePermit2 = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: updatedPricePer,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 upgradeDigest2 = sigUtils.getTypedDataHash(upgradePermit2);

        (uint8 upgradeV2, bytes32 upgradeR2, bytes32 upgradeS2) = vm.sign(bobKeys, upgradeDigest2);

        dAgora.upgradeMemebership(
            1,
            dAgoraMemberships.Membership(3),
            _deadline,
            upgradeV2,
            upgradeR2,
            upgradeS2
        );

        assertEq(dAgora.checkTokenTier(1), 3);

        dAgora.cancelMembership(1);

        vm.warp(86400 * 2);

        assertEq(dAgora.isValidMembership(1), false);

        uint256 renewPrice = (5 ether) * 11;
        uint256 renewDeadline = block.timestamp + 600;

        SigUtils.Permit memory renewPermit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: renewPrice,
            nonce: dAgora.nonces(address(bob)),
            deadline: renewDeadline
        });

        bytes32 renewDigest = sigUtils.getTypedDataHash(renewPermit);

        (uint8 renewV, bytes32 renewR, bytes32 renewS) = vm.sign(bobKeys, renewDigest);

        dAgora.renewMembership(
            1,
            12,
            renewDeadline,
            renewV,
            renewR,
            renewS
        );

        assertEq(dAgora.isValidMembership(1), true);
        vm.stopPrank();
    }

    function testFailAlreadyMember() public {
        vm.startPrank(bob);

        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + periclesiaPrice;
        
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);


        dAgora.mintdAgoraMembership(
            1, 
            dAgoraMemberships.Membership(3), 
            _deadline, 
            v, 
            r, 
            s
        );

        SigUtils.Permit memory permit2 = SigUtils.Permit({
            owner:  address(bob),
            spender: address(dAgora),
            value:  price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest2 = sigUtils.getTypedDataHash(permit2);

        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(bobKeys, digest2);

        dAgora.mintdAgoraMembership(
            1, 
            dAgoraMemberships.Membership(1), 
            _deadline, 
            v2, 
            r2, 
            s2
        );

        vm.stopPrank();
    }

    function testFailWrongSig() public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + dagorianPrice;

        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(alice), // wrong address
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintdAgoraMembership(
            1, 
            dAgoraMemberships.Membership(2), 
            _deadline, 
            v, 
            r, 
            s
        );

        vm.stopPrank();
    }

    function testFailMintdAgoraianNotENoughBalance() public {
        vm.startPrank(alice);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + dagorianPrice;

        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintdAgoraMembership(
            1, 
            dAgoraMemberships.Membership(1), 
            _deadline, 
            v, 
            r, 
            s
        );

        vm.stopPrank();
    }

    function testFailMintHoptileNotENoughBalance() public {
        vm.startPrank(alice);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + hoplitePrice;

        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintdAgoraMembership(
            1, 
            dAgoraMemberships.Membership(2), 
            _deadline, 
            v, 
            r, 
            s
        );

        vm.stopPrank();
    }

    function testFailMintPericlesiaNotENoughBalance() public {
        vm.startPrank(alice);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + periclesiaPrice;

        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintdAgoraMembership(
            1, 
            dAgoraMemberships.Membership(3), 
            _deadline, 
            v, 
            r, 
            s
        );

        vm.stopPrank();
    }

    function testCancel() public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + dagorianPrice;

        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintdAgoraMembership(
            1, 
            dAgoraMemberships.Membership(1), 
            _deadline, 
            v, 
            r, 
            s
        );

        dAgora.isValidMembership(1);

        dAgora.cancelMembership(1);
        dAgora.membershipExpiresIn(1);
        vm.warp(86405);
        assertEq(dAgora.isValidMembership(1), false);
        vm.stopPrank();
    }

    function testFailCancelNotTokenOwner() public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + dagorianPrice;

        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintdAgoraMembership(
            1, 
            dAgoraMemberships.Membership(1), 
            _deadline, 
            v, 
            r, 
            s
        );
        vm.stopPrank();

        vm.startPrank(alice);
        dAgora.cancelMembership(1);
        vm.stopPrank();
    }
}
