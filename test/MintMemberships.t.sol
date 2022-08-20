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

contract MintMembershipsTest is Test {
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

    bytes32 public jobId = 0xf7f77ea15719ea30bd2a584962ab273b1116f0e70fe80bbb0b30557d0addb7f3;

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

    function testMint_dAgorian() public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + dagorianPrice;
        dai.approve(address(dAgora), price);
        dAgora.mintdAgoraianTier(1, address(dai));
        assertEq(dAgora.totalSupply(), 1);
        assertEq(dAgora.balanceOf(address(bob)), 1);
        assertEq(dAgora.checkTokenTier(1), 1);
        vm.stopPrank();
    }

    function testMint_Hoptile() public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + hoplitePrice;
        dai.approve(address(dAgora), price);
        dAgora.mintHoptileTier(1, address(dai));
        assertEq(dAgora.totalSupply(), 1);
        assertEq(dAgora.balanceOf(address(bob)), 1);
        assertEq(dAgora.checkTokenTier(1), 2);
        vm.stopPrank();
    }

    function testMint_Periclesia() public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + periclesiaPrice;
        dai.approve(address(dAgora), price);
        dAgora.mintPericlesiaTier(1, address(dai));

        vm.stopPrank();
    }

    function testFailAlreadyMember() public {
        vm.startPrank(bob);
       
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + periclesiaPrice - 5 ether;
        dai.approve(address(dAgora), price);
        dAgora.mintPericlesiaTier(1, address(dai));

        dAgora.mintPericlesiaTier(1, address(dai));
        vm.stopPrank();
    }

    function testFailMintPericlesiaWrongERC20() public {
        vm.startPrank(bob);
        dAgora.mintPericlesiaTier(1, address(token));
        vm.stopPrank();
    }

    function testFailMintHoptileWrongERC20() public {
        vm.startPrank(bob);
        dAgora.mintHoptileTier(1, address(token));
        vm.stopPrank();
    }

    function testFailMintdAgoraianWrongERC20() public {
        vm.startPrank(bob);
        dAgora.mintdAgoraianTier(1, address(token));
        vm.stopPrank();
    }

    function testFailMintPericlesiaWrongDAIAllowance() public {
        vm.startPrank(bob);
        dai.approve(address(dAgora), 10);
        dAgora.mintPericlesiaTier(1, address(dai));
        vm.stopPrank();
    }

    function testFailMintHoptileWrongDAIAllowance() public {
        vm.startPrank(bob);
        dai.approve(address(dAgora), 10);
        dAgora.mintHoptileTier(1, address(dai));
        vm.stopPrank();
    }

    function testFailMintdAgoraianWrongDAIAllowance() public {
        vm.startPrank(bob);
        dai.approve(address(dAgora), 10);
        dAgora.mintdAgoraianTier(1, address(dai));
        vm.stopPrank();
    }

    function testFailMintdAgoraianWrongUSDCAllowance() public {
        vm.startPrank(bob);
            usdc.approve(address(dAgora), 10);
            dAgora.mintdAgoraianTier(1, address(usdc));
        vm.stopPrank();
    }

    function testFailMintHoptileWrongUSDCAllowance() public {
        vm.startPrank(bob);
            usdc.approve(address(dAgora), 10);
            dAgora.mintHoptileTier(1, address(usdc));
        vm.stopPrank();
    }

    function testFailMintPericlesiaWrongUSDCAllowance() public {
        vm.startPrank(bob);
            usdc.approve(address(dAgora), 10);
            dAgora.mintPericlesiaTier(1, address(usdc));
        vm.stopPrank();
    }

    function testFailMintdAgoraianNotENoughBalance() public {
        vm.startPrank(alice);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + dagorianPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintdAgoraianTier(1, address(dai));
        vm.stopPrank();
    }

    function testFailMintHoptileNotENoughBalance() public {
        vm.startPrank(alice);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + hoplitePrice;
            dai.approve(address(dAgora), price);
            dAgora.mintHoptileTier(1, address(dai));
        vm.stopPrank();
    }

    function testFailMintPericlesiaNotENoughBalance() public {
        vm.startPrank(alice);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + periclesiaPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintPericlesiaTier(1, address(dai));
        vm.stopPrank();
    }

    function testCancel() public {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + dagorianPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintdAgoraianTier(1, address(dai));
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
            dai.approve(address(dAgora), price);
            dAgora.mintdAgoraianTier(1, address(dai));
        vm.stopPrank();
        vm.startPrank(alice);
            dAgora.cancelMembership(1);
        vm.stopPrank();
    }

}
