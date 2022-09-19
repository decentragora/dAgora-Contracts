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


contract UpgradeMembershipTests is Test {
    address dAgoraTreasury = address(0x1337);
    address public bob;
    address public minter;
    address public alice;
    address carol = address(0x133704);
    address dave = address(0x133705);
    address eve = address(0x133706);
    address frank = address(0x133707);
    address grace = address(0x133708);
    address harry = address(0x133709);
    address ida = address(0x133710);
    address jake = address(0x133711);
    address kate = address(0x133712);
    address luke = address(0x133713);
    address molly = address(0x133714);
    address nancy = address(0x133715);

    dAgoraMemberships dAgora;
    ChainLink link;
    MockOperator operator;
    TestDAI dai;
    SigUtils sigUtils;

    uint256 oracleFee = 1 * 10 ** 17;
    uint256 ecceliaePrice = 0;
    uint256 dagorianPrice = 50 * 10 ** 18;
    uint256 hoplitePrice = 80 * 10 ** 18;
    uint256 periclesiaPrice = 1000 * 10 ** 18;
    uint256 monthlyPrice = 5 * 10 ** 18;
    uint256 _deadline = block.timestamp + 600;

    uint256 public bobKeys = 0xB0B;
    uint256 public minterKeys = 0xB0BdA7;
    uint256 public aliceKeys = 0xA1C3;

    bytes32 public jobId = "3950";

    function setUp() public {
        bob = vm.addr(bobKeys);
        minter = vm.addr(minterKeys);
        alice = vm.addr(aliceKeys);
        link = new ChainLink();
        vm.startPrank(dAgoraTreasury);
        dai = new TestDAI();

        sigUtils = new SigUtils(dai.DOMAIN_SEPARATOR());
        link._mint();
        operator = new MockOperator(address(link));

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
        dAgora.giftMembership(address(alice), 1, dAgoraMemberships.Membership(0));
        assertEq(dAgora.balanceOf(address(alice)), 1, 'alice should have 1 membership');
        vm.stopPrank();

        vm.startPrank(bob);
        dai._mint();

        vm.stopPrank();
    }

    function testUpgrade_DAgorainTo_Hoplite() public {
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

        assertEq(dAgora.checkTokenTier(2), 1);
        uint256 upgradeCost = hoplitePrice - dagorianPrice;
        dai.approve(address(dAgora), upgradeCost);

        SigUtils.Permit memory upgradePermit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: upgradeCost,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 upgradeDigest = sigUtils.getTypedDataHash(upgradePermit);

        (uint8 upgradeV, bytes32 upgradeR, bytes32 upgradeS) = vm.sign(bobKeys, upgradeDigest);

        dAgora.upgradeMemebership(
            2,
            dAgoraMemberships.Membership(2),
            _deadline,
            upgradeV,
            upgradeR,
            upgradeS
        );
        
        assertEq(dAgora.checkTokenTier(2), 2);
        vm.stopPrank();
    }

    function testUpgrade_DAgorainTo_Periclesia() public {
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

        assertEq(dAgora.checkTokenTier(2), 1);
        uint256 upgradeCost = (periclesiaPrice + hoplitePrice) - dagorianPrice;

        SigUtils.Permit memory upgradePermit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: upgradeCost,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 upgradeDigest = sigUtils.getTypedDataHash(upgradePermit);

        (uint8 upgradeV, bytes32 upgradeR, bytes32 upgradeS) = vm.sign(bobKeys, upgradeDigest);

        dAgora.upgradeMemebership(
            2,
            dAgoraMemberships.Membership(3),
            _deadline,
            upgradeV,
            upgradeR,
            upgradeS
        );

        assertEq(dAgora.checkTokenTier(2), 3);
        vm.stopPrank();
    }

    function testUpgradeHoptileTo_Periclesia() public {
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

        assertEq(dAgora.checkTokenTier(2), 2);
        uint256 upgradeCost = (periclesiaPrice - (dagorianPrice + hoplitePrice));
       
        SigUtils.Permit memory upgradePermit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: upgradeCost,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 upgradeDigest = sigUtils.getTypedDataHash(upgradePermit);

        (uint8 upgradeV, bytes32 upgradeR, bytes32 upgradeS) = vm.sign(bobKeys, upgradeDigest);

        dAgora.upgradeMemebership(
            2,
            dAgoraMemberships.Membership(3),
            _deadline,
            upgradeV,
            upgradeR,
            upgradeS
        );

        assertEq(dAgora.checkTokenTier(2), 3);
        vm.stopPrank();
    }

    function testUpgradeEcclesia_To_dAgorian() public {
        vm.startPrank(alice);
        dai._mint();
        uint256 upgradeCost = (dagorianPrice);

        SigUtils.Permit memory upgradePermit = SigUtils.Permit({
            owner: address(alice),
            spender: address(dAgora),
            value: upgradeCost,
            nonce: dAgora.nonces(address(alice)),
            deadline: _deadline
        });

        bytes32 upgradeDigest = sigUtils.getTypedDataHash(upgradePermit);

        (uint8 upgradeV, bytes32 upgradeR, bytes32 upgradeS) = vm.sign(aliceKeys, upgradeDigest);

        dAgora.upgradeMemebership(
            1,
            dAgoraMemberships.Membership(1),
            _deadline,
            upgradeV,
            upgradeR,
            upgradeS
        );
    }

    function testUpgradeEcclesia_to_Hoptile() public {
        vm.startPrank(alice);
        dai._mint();
        uint256 upgradeCost = (hoplitePrice + dagorianPrice);

        SigUtils.Permit memory upgradePermit = SigUtils.Permit({
            owner: address(alice),
            spender: address(dAgora),
            value: upgradeCost,
            nonce: dAgora.nonces(address(alice)),
            deadline: _deadline
        });

        bytes32 upgradeDigest = sigUtils.getTypedDataHash(upgradePermit);

        (uint8 upgradeV, bytes32 upgradeR, bytes32 upgradeS) = vm.sign(aliceKeys, upgradeDigest);

        dAgora.upgradeMemebership(
            1,
            dAgoraMemberships.Membership(2),
            _deadline,
            upgradeV,
            upgradeR,
            upgradeS
        );
    }

    function testUpgradeEcclesia_To_Perclesia() public {
        vm.startPrank(alice);
        dai._mint();
        uint256 upgradeCost = (periclesiaPrice + dagorianPrice + hoplitePrice);

        SigUtils.Permit memory upgradePermit = SigUtils.Permit({
            owner: address(alice),
            spender: address(dAgora),
            value: upgradeCost,
            nonce: dAgora.nonces(address(alice)),
            deadline: _deadline
        });

        bytes32 upgradeDigest = sigUtils.getTypedDataHash(upgradePermit);

        (uint8 upgradeV, bytes32 upgradeR, bytes32 upgradeS) = vm.sign(aliceKeys, upgradeDigest);

        dAgora.upgradeMemebership(
            1,
            dAgoraMemberships.Membership(3),
            _deadline,
            upgradeV,
            upgradeR,
            upgradeS
        );
    }

    function testFailUpgradeNotEnoughFunds() public {
        vm.startPrank(alice);
        uint256 upgradeCost = (hoplitePrice);

        SigUtils.Permit memory upgradePermit = SigUtils.Permit({
            owner: address(alice),
            spender: address(dAgora),
            value: upgradeCost,
            nonce: dAgora.nonces(address(alice)),
            deadline: _deadline
        });

        bytes32 upgradeDigest = sigUtils.getTypedDataHash(upgradePermit);

        (uint8 upgradeV, bytes32 upgradeR, bytes32 upgradeS) = vm.sign(aliceKeys, upgradeDigest);

        dAgora.upgradeMemebership(
            1,
            dAgoraMemberships.Membership(2),
            _deadline,
            upgradeV,
            upgradeR,
            upgradeS
        );
    }

    function testFailUpgradeWrongPrice() public {
        vm.startPrank(alice);
        dai._mint();
        uint256 upgradeCost = (hoplitePrice);

        SigUtils.Permit memory upgradePermit = SigUtils.Permit({
            owner: address(alice),
            spender: address(dAgora),
            value: upgradeCost,
            nonce: dAgora.nonces(address(alice)),
            deadline: _deadline
        });

        bytes32 upgradeDigest = sigUtils.getTypedDataHash(upgradePermit);

        (uint8 upgradeV, bytes32 upgradeR, bytes32 upgradeS) = vm.sign(aliceKeys, upgradeDigest);

        dAgora.upgradeMemebership(
            1,
            dAgoraMemberships.Membership(2),
            _deadline,
            upgradeV,
            upgradeR,
            upgradeS
        );

    }
    
    function testFailUpgrade_SameTier() public {
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

        assertEq(dAgora.checkTokenTier(2), 3);
        uint256 upgradeCost = (periclesiaPrice - (dagorianPrice + hoplitePrice));
        
        SigUtils.Permit memory upgradePermit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: upgradeCost,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 upgradeDigest = sigUtils.getTypedDataHash(upgradePermit);

        (uint8 upgradeV, bytes32 upgradeR, bytes32 upgradeS) = vm.sign(bobKeys, upgradeDigest);

        dAgora.upgradeMemebership(
            2,
            dAgoraMemberships.Membership(3),
            _deadline,
            upgradeV,
            upgradeR,
            upgradeS
        );

        assertEq(dAgora.checkTokenTier(2), 3);
        vm.stopPrank();
    }

    function testFailUpgrade_LowerTier() public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + (hoplitePrice);
    
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

        assertEq(dAgora.checkTokenTier(2), 1);
        uint256 upgradeCost = (periclesiaPrice - (dagorianPrice + hoplitePrice));
        
        SigUtils.Permit memory upgradePermit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: upgradeCost,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 upgradeDigest = sigUtils.getTypedDataHash(upgradePermit);

        (uint8 upgradeV, bytes32 upgradeR, bytes32 upgradeS) = vm.sign(bobKeys, upgradeDigest);

        dAgora.upgradeMemebership(
            2,
            dAgoraMemberships.Membership(1),
            _deadline,
            upgradeV,
            upgradeR,
            upgradeS
        );

        assertEq(dAgora.checkTokenTier(2), 1);
        vm.stopPrank();
    }

    function testFailUpgradeNotTokenOwner() public {
        vm.startPrank(bob);
        uint256 upgradeCost = (dagorianPrice);
        
        SigUtils.Permit memory upgradePermit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: upgradeCost,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 upgradeDigest = sigUtils.getTypedDataHash(upgradePermit);

        (uint8 upgradeV, bytes32 upgradeR, bytes32 upgradeS) = vm.sign(bobKeys, upgradeDigest);

        dAgora.upgradeMemebership(
            1,
            dAgoraMemberships.Membership(1),
            _deadline,
            upgradeV,
            upgradeR,
            upgradeS
        );

        vm.stopPrank();
    }
}
