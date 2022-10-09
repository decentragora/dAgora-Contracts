// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/Vm.sol";
import {dAgoraMemberships} from "../src/dAgoraMemberships.sol";
import {ChainLink} from "../src/mock/linkToken.sol";
import {DAI} from "../src/mock/DAI.sol";
import {SigUtils} from "../src/mock/sigUtils.sol";
import {MockOperator} from "../src/mock/mockOperator.sol";

contract MembershipFuzzTests is Test {
    address dAgoraTreasury = address(0x1337);
    // address signer = address(0x133702);
    address public bob;
    address public minter;
    address alice = address(0x133703);
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


    SigUtils sigUtils;
    dAgoraMemberships dAgora;
    ChainLink link;
    MockOperator operator;
    DAI dai;

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
        dai = new DAI();

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

    function testMint_dAgorian(uint96 months) public {
        vm.startPrank(bob);
        vm.assume(months > 0 && months <= 12);
        uint96 amountOfMonths = months;
        if(months == 12) {
            amountOfMonths = 11;
        }
        uint256 monthlyCost = ((5 ether) * amountOfMonths);
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
            amountOfMonths, 
            dAgoraMemberships.Membership(1), 
            _deadline, 
            v, 
            r, 
            s
        );

        assertEq(dAgora.totalSupply(), 1);
        assertEq(dAgora.balanceOf(address(bob)), 1);
        assertEq(dAgora.checkTokenTier(1), 1);
        vm.stopPrank();
    }


    function testMint_Hoptile(uint96 months) public {
        vm.startPrank(bob);
        vm.assume(months > 0 && months <= 12);
        uint96 amountOfMonths = months;
        if(months == 12) {
            amountOfMonths = 11;
        }
        uint256 monthlyCost = ((5 ether) * amountOfMonths);
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
            amountOfMonths,
            dAgoraMemberships.Membership(2), 
            _deadline, 
            v, 
            r, 
            s
        );

        assertEq(dAgora.totalSupply(), 1);
        assertEq(dAgora.balanceOf(address(bob)), 1);
        assertEq(dAgora.checkTokenTier(1), 2);
        vm.stopPrank();
    }

    function testMint_Periclesia(uint96 months) public {
        vm.startPrank(bob);
        vm.assume(months > 0 && months <= 12);
        uint96 amountOfMonths = months;
        if(months == 12) {
            amountOfMonths = 11;
        }
        uint256 monthlyCost = ((5 ether) * amountOfMonths);
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
            amountOfMonths, 
            dAgoraMemberships.Membership(3), 
            _deadline, 
            v, 
            r, 
            s
        );

        assertEq(dAgora.totalSupply(), 1);
        assertEq(dAgora.balanceOf(address(bob)), 1);
        assertEq(dAgora.checkTokenTier(1), 3);

        vm.stopPrank();
    }

    function testFailAlreadyMember(uint96 months) public {
        vm.startPrank(bob);
        vm.assume(months > 0 && months <= 12);
        uint96 amountOfMonths = months;
        if(months == 12) {
            amountOfMonths = 11;
        }
        uint256 monthlyCost = ((5 ether) * amountOfMonths);
        uint256 price = monthlyCost + periclesiaPrice - 5 ether;
        dai.approve(address(dAgora), price);

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
            amountOfMonths,
            dAgoraMemberships.Membership(3), 
            _deadline, 
            v, 
            r, 
            s
        );

        SigUtils.Permit memory permit2 = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest2 = sigUtils.getTypedDataHash(permit2);

        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(bobKeys, digest2);

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

    function testRenewMembership(uint96 renewMonths) public {
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

        vm.assume(renewMonths > 0 && renewMonths <= 12);
        uint96 amountOfMonths = renewMonths;
        if(renewMonths == 12) {
            amountOfMonths = 11;
        }
        uint256 renewPrice = ((5 ether) * amountOfMonths);
        uint256 renewDeadline = block.timestamp + 666;

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
            amountOfMonths,
            renewDeadline, 
            renewV,
            renewR,
            renewS
        );

        vm.stopPrank();
    }


    function testUpgradeMembership(uint96 newTier) public {
        uint256 upgradeCost;
        vm.startPrank(dAgoraTreasury);
        dAgora.giftMembership(address(bob), 1, dAgoraMemberships.Membership(0));
        vm.stopPrank();
        vm.assume(newTier > 0 && newTier <= 3);
        vm.startPrank(bob);
        if (newTier == 1) {
            upgradeCost = dagorianPrice;
        } else if (newTier == 2) {
            upgradeCost = hoplitePrice + dagorianPrice;
        } else if (newTier == 3) {
            upgradeCost = periclesiaPrice + hoplitePrice + dagorianPrice;
        }

        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: upgradeCost,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.upgradeMembership(
            1, 
            dAgoraMemberships.Membership(uint8(newTier)), 
            _deadline, 
            v, 
            r, 
            s
        );
        vm.stopPrank();
    }
}
