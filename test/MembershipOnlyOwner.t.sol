// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/Vm.sol";
import {dAgoraMemberships} from "../src/dAgoraMemberships.sol";
import {ChainLink} from "../src/mock/linkToken.sol";
import {TestDAI} from "../src/mock/testDAI.sol";
import {MockOperator} from "../src/mock/mockOperator.sol";
import {SigUtils} from "../src/mock/sigUtils.sol";


contract OnlyOwnerFunctionsTest is Test {
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

    function testSetDAgoraianPrice() public {
        vm.startPrank(dAgoraTreasury);
        dAgora.setdAgorianPrice(20 * 10 ** 18);
        assertEq(dAgora.dAgorianPrice(), 20 * 10 ** 18);
        vm.stopPrank();
    }

    function testSetHoptilePrice() public {
        vm.startPrank(dAgoraTreasury);
        dAgora.setHoplitePrice(30 * 10 ** 18);
        assertEq(dAgora.hoplitePrice(), 30 * 10 ** 18);
        vm.stopPrank();
    }

    function testSetPericlesiaPrice() public {
        vm.startPrank(dAgoraTreasury);
        dAgora.setPericlesiaPrice(40 * 10 ** 18);
        assertEq(dAgora.periclesiaPrice(), 40 * 10 ** 18);
        vm.stopPrank();
    }

    function testSetRewardedRole() public {
        vm.startPrank(dAgoraTreasury);
        dAgora.setRewardedRole(3895);
        assertEq(dAgora.rewardedRole(), 3895);
        vm.stopPrank();
    }


    function testTogglePause() public {
        vm.startPrank(dAgoraTreasury);
        dAgora.togglePaused();
        assertEq(dAgora.paused(), true);
        dAgora.togglePaused();
        assertEq(dAgora.paused(), false);
        vm.stopPrank();
    }

    function testSetDiscountRate() public {
        vm.startPrank(dAgoraTreasury);
        dAgora.setDiscountRate(10 * 10 ** 18);
        assertEq(dAgora.discountRate(), 10 * 10 ** 18);
        vm.stopPrank();
    }

    function testSetMonthlyPrice() public {
        vm.startPrank(dAgoraTreasury);
        dAgora.setMonthlyPrice(20 * 10 ** 18);
        assertEq(dAgora.monthlyPrice(), 20 * 10 ** 18);
        vm.stopPrank();
    }

    function testSet_dAgoraTreasury() public {
        vm.startPrank(dAgoraTreasury);
        dAgora.setdAgoraTreasury(address(bob));
        assertEq(dAgora.dAgoraTreasury(), address(bob));
        vm.stopPrank();
    }

    function testSetGuildId() public {
        vm.startPrank(dAgoraTreasury);
        dAgora.setGuildId("9009");
        vm.stopPrank();
    }

    function testGiftMembership() public {
        vm.startPrank(dAgoraTreasury);
        dAgora.giftMembership(address(bob), 4, dAgoraMemberships.Membership(1));
        assertEq(dAgora.balanceOf(bob), 1);
        assertEq(dAgora.isValidMembership(1), true);
        assertEq(dAgora.checkTokenTier(1), 1);
        vm.stopPrank();
    }

    function testGiftUpgrade() public {
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

        assertEq(dAgora.checkTokenTier(1), 1);
        vm.stopPrank();
        vm.startPrank(dAgoraTreasury);
        dAgora.giftUpgrade(1, dAgoraMemberships.Membership(2));
        assertEq(dAgora.checkTokenTier(1), 2);
        vm.stopPrank();
    }

    function testAddTimeForMembership() public {
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
        uint256 mintTime = dAgora.membershipExpiresIn(1);
        vm.startPrank(dAgoraTreasury);
        dAgora.addTimeForMembership(1, 6);
        uint256 addedTime = dAgora.membershipExpiresIn(1);
        assertTrue(addedTime > mintTime);
        vm.stopPrank();
    }

    ///////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////Failed Tests//////////////////////////////////////////////

    function testFailSetDAgoraianPrice() public {
        vm.startPrank(bob);
        dAgora.setdAgorianPrice(20 * 10 ** 18);
        vm.stopPrank();
    }

    function testFailSetHoptilePrice() public {
        vm.startPrank(bob);
        dAgora.setHoplitePrice(30 * 10 ** 18);
        vm.stopPrank();
    }

    function testFailSetPericlesiaPrice() public {
        vm.startPrank(bob);
        dAgora.setPericlesiaPrice(40 * 10 ** 18);
        vm.stopPrank();
    }

    function testFailSetRewardedRole() public {
        vm.startPrank(bob);
        dAgora.setRewardedRole(3895);
        vm.stopPrank();
    }


    function testFailTogglePaused() public {
        vm.startPrank(bob);
        dAgora.togglePaused();
        vm.stopPrank();
    }

    function testFailSetDiscountRate() public {
        vm.startPrank(bob);
        dAgora.setDiscountRate(1000 * 10 ** 18);
        vm.stopPrank();
    }

    function testFailSetMonthlyPrice() public {
        vm.startPrank(bob);
        dAgora.setMonthlyPrice(20 * 10 ** 18);
        vm.stopPrank();
    }

    function testFailSet_dAgoraTreasury() public {
        vm.startPrank(bob);
        dAgora.setdAgoraTreasury(address(bob));
        vm.stopPrank();
    }

    function testFailSetGuildId() public {
        vm.startPrank(bob);
        dAgora.setGuildId("9009");
        vm.stopPrank();
    }

    function testFailGiftSelfMembership() public {
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

        dAgora.giftMembership(address(bob), 12, dAgoraMemberships.Membership(3));
        vm.stopPrank();
    }

    function testFailGiftSelfUpgrade() public {
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

        dAgora.giftUpgrade(1, dAgoraMemberships.Membership(3));
        vm.stopPrank();
    }

    function testFailAddTimeForSelf() public {
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

        dAgora.addTimeForMembership(1, 6);
        vm.stopPrank();
    }
}
