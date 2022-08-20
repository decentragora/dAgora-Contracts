// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/Vm.sol";
import {dAgoraMemberships} from "../src/dAgoraMemberships.sol";
import {ChainLink} from "../src/mock/linkToken.sol";
import {TestDAI} from "../src/mock/testDAI.sol";
import {TestUSDC} from "../src/mock/testUSDC.sol";
import {Token} from "../src/mock/token.sol";
import {MockOperator} from "../src/mock/mockOperator.sol";

contract MembershipFuzzTests is Test {
    address dAgoraTreasury = address(0x1337);
    address signer = address(0x133702);
    address alice = address(0x133703);
    address bob = address(0x133704);
    address chrome = address(0xcb5c05B9916B49adf97cC31a0c7089F3B4Cfa8b1);
    address user1 = address(0x133705);
    address user2 = address(0x133706);
    address user3 = address(0x133707);

    dAgoraMemberships dAgora;
    ChainLink link;
    MockOperator operator;
    TestDAI dai;
    TestUSDC usdc;
    Token token;

    uint256 oracleFee = 1 * 10 ** 17;
    uint256 ecceliaePrice = 0;
    uint256 dagorianPrice = 50 * 10 ** 18;
    uint256 hoplitePrice = 80 * 10 ** 18;
    uint256 periclesiaPrice = 1000 * 10 ** 18;
    uint256 monthlyPrice = 5 * 10 ** 18;

    bytes32 public jobId = "3950";

    function setUp() public {
        link = new ChainLink();
        vm.startPrank(dAgoraTreasury);
        dai = new TestDAI();
        token = new Token();
        usdc = new TestUSDC();

        link._mint();
        operator = new MockOperator(address(link));

        link.transfer(address(operator), 100);
        dAgora = new dAgoraMemberships(
                'ipfs://BaseURIOrCID/',
                address(dai),
                address(usdc),
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
            usdc._mint();
        vm.stopPrank();
    }

    // function testMintFreeClaim() public {
    //     vm.startPrank(bob);
    //         dAgora.mintFreeClaim();
    //     vm.stopPrank();
    // }

    function testMint_dAgorian_DAI(uint96 months) public {
        vm.startPrank(bob);
        vm.assume(months > 0 && months <= 12);
            uint256 monthlyCost = ((5 ether) * months);
            uint256 price = monthlyCost + dagorianPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintdAgoraianTier(months, address(dai));
        assertEq(dAgora.totalSupply(), 1);
        assertEq(dAgora.balanceOf(address(bob)), 1);
        assertEq(dAgora.checkTokenTier(1), 1);
        vm.stopPrank();
    }

    function testMint_dAgorian_USDC(uint96 months) public {
        vm.startPrank(bob);
        vm.assume(months > 0 && months <= 12);
            uint256 monthlyCost = ((5 ether) * months);
            uint256 price = monthlyCost + dagorianPrice;
            usdc.approve(address(dAgora), price);
            dAgora.mintdAgoraianTier(months, address(usdc));
        assertEq(dAgora.totalSupply(), 1);
        assertEq(dAgora.balanceOf(address(bob)), 1);
        assertEq(dAgora.checkTokenTier(1), 1);
        vm.stopPrank();
    }


    function testMint_Hoptile_DAI(uint96 months) public {
        vm.startPrank(bob);
        vm.assume(months > 0 && months <= 12);
            uint256 monthlyCost = ((5 ether) * months);
            uint256 price = monthlyCost + hoplitePrice;
            dai.approve(address(dAgora), price);
            dAgora.mintHoptileTier(months, address(dai));
        assertEq(dAgora.totalSupply(), 1);
        assertEq(dAgora.balanceOf(address(bob)), 1);
        assertEq(dAgora.checkTokenTier(1), 2);
        vm.stopPrank();
    }

    function testMint_Hoptile_USDC(uint96 months) public {
        vm.startPrank(bob);
        vm.assume(months > 0 && months <= 12);
            uint256 monthlyCost = ((5 ether) * months);
            uint256 price = monthlyCost + hoplitePrice;
            usdc.approve(address(dAgora), price);
            dAgora.mintHoptileTier(months, address(usdc));
        assertEq(dAgora.totalSupply(), 1);
        assertEq(dAgora.balanceOf(address(bob)), 1);
        assertEq(dAgora.checkTokenTier(1), 2);
        vm.stopPrank();
    }

    function testMint_Periclesia_DAI(uint96 months) public {
        vm.startPrank(bob);
        vm.assume(months > 0 && months <= 12);
        uint256 monthlyCost = ((5 ether) * months);
        uint256 price = monthlyCost + periclesiaPrice;
        dai.approve(address(dAgora), price);
        dAgora.mintPericlesiaTier(months, address(dai));

        vm.stopPrank();
    }

    function testMint_Periclesia_USDC(uint96 months) public {
        vm.startPrank(bob);
        vm.assume(months > 0 && months <= 12);
        uint256 monthlyCost = ((5 ether) * months);
        uint256 price = monthlyCost + periclesiaPrice;
        usdc.approve(address(dAgora), price);
        dAgora.mintPericlesiaTier(months, address(usdc));

        vm.stopPrank();
    }

    function testFailAlreadyMember(uint96 months) public {
        vm.startPrank(bob);
        vm.assume(months > 0 && months <= 12);
        uint256 monthlyCost = ((5 ether) * months);
        uint256 price = monthlyCost + periclesiaPrice - 5 ether;
        dai.approve(address(dAgora), price);
        dAgora.mintPericlesiaTier(months, address(dai));

        dAgora.mintPericlesiaTier(months, address(dai));
        vm.stopPrank();
    }

    function testRenewMembership_DAI(uint96 renewMonths) public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + periclesiaPrice;
        dai.approve(address(dAgora), price);
        dAgora.mintPericlesiaTier(1, address(dai));
        vm.assume(renewMonths > 0 && renewMonths <= 12);
        uint256 renewPrice = ((5 ether) * renewMonths);
        dai.approve(address(dAgora), renewPrice);
        dAgora.renewMembership(1, renewMonths, address(dai));
        vm.stopPrank();
    }
    
    function testRenewMembership_USDC(uint96 renewMonths) public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + periclesiaPrice;
        usdc.approve(address(dAgora), price);
        dAgora.mintPericlesiaTier(1, address(usdc));
        vm.assume(renewMonths > 0 && renewMonths <= 12);
        uint256 renewPrice = ((5 ether) * renewMonths);
        usdc.approve(address(dAgora), renewPrice);
        dAgora.renewMembership(1, renewMonths, address(usdc));
        vm.stopPrank();
    }
}
