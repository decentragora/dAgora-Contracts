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

contract RenewMembershipTests is Test {
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

    function testRenewMembershipTier1_DAI() public {
        //User Mint's A Membership
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + dagorianPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintdAgoraianTier(1, address(dai));
            dAgora.membershipExpiresIn(1);
            dAgora.isValidMembership(1);
            dAgora.checkTokenTier(1);
            vm.warp(111111);
            dAgora.membershipExpiresIn(1);
            uint256 renewCost = ((5 ether) * 4);
            dai.approve(address(dAgora), renewCost);
            dAgora.renewMembership(1, 4, address(dai));
            dAgora.membershipExpiresIn(1);
        vm.stopPrank();
    }

    function testRenewMembershipTier1_USDC() public {
        //User Mint's A Membership
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + dagorianPrice;
            usdc.approve(address(dAgora), price);
            dAgora.mintdAgoraianTier(1, address(usdc));
            dAgora.membershipExpiresIn(1);
            dAgora.isValidMembership(1);
            dAgora.checkTokenTier(1);
            vm.warp(111111);
            dAgora.membershipExpiresIn(1);
            uint256 renewCost = ((5 ether) * 4);
            usdc.approve(address(dAgora), renewCost);
            dAgora.renewMembership(1, 4, address(usdc));
            dAgora.membershipExpiresIn(1);
        vm.stopPrank();
    }

    function testRenewMembershipTier2_DAI() public {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + hoplitePrice;
            dai.approve(address(dAgora), price);
            dAgora.mintHoptileTier(1, address(dai));
            dAgora.membershipExpiresIn(1);
            dAgora.isValidMembership(1);
            dAgora.checkTokenTier(1);
            vm.warp(111111);
            dAgora.membershipExpiresIn(1);
            uint256 renewCost = ((5 ether) * 4);
            dai.approve(address(dAgora), renewCost);
            dAgora.renewMembership(1, 4, address(dai));
            dAgora.membershipExpiresIn(1);
    }

    function testRenewMembershipTier2_USDC() public {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + hoplitePrice;
            usdc.approve(address(dAgora), price);
            dAgora.mintHoptileTier(1, address(usdc));
            dAgora.membershipExpiresIn(1);
            dAgora.isValidMembership(1);
            dAgora.checkTokenTier(1);
            vm.warp(111111);
            dAgora.membershipExpiresIn(1);
            uint256 renewCost = ((5 ether) * 4);
            usdc.approve(address(dAgora), renewCost);
            dAgora.renewMembership(1, 4, address(usdc));
            dAgora.membershipExpiresIn(1);
        vm.stopPrank();
    }

    function testRenewMembershipTier3_DAI() public {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + periclesiaPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintPericlesiaTier(1, address(dai));
            dAgora.membershipExpiresIn(1);
            dAgora.isValidMembership(1);
            dAgora.checkTokenTier(1);
            vm.warp(111111);
            dAgora.membershipExpiresIn(1);
            uint256 renewCost = ((5 ether) * 4);
            dai.approve(address(dAgora), renewCost);
            dAgora.renewMembership(1, 4, address(dai));
            dAgora.membershipExpiresIn(1);
        vm.stopPrank();
    }

    function testRenewMembershipTier3_USDC() public {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + periclesiaPrice;
            usdc.approve(address(dAgora), price);
            dAgora.mintPericlesiaTier(1, address(usdc));
            dAgora.membershipExpiresIn(1);
            dAgora.isValidMembership(1);
            dAgora.checkTokenTier(1);
            vm.warp(111111);
            dAgora.membershipExpiresIn(1);
            uint256 renewCost = ((5 ether) * 4);
            usdc.approve(address(dAgora), renewCost);
            dAgora.renewMembership(1, 4, address(usdc));
            dAgora.membershipExpiresIn(1);
        vm.stopPrank();
    }

    function testRenewExpiredToken_DAI() public {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + periclesiaPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintPericlesiaTier(1, address(dai));
            dAgora.membershipExpiresIn(1);
            dAgora.isValidMembership(1);
            dAgora.checkTokenTier(1);
            vm.warp(2778400);
            dAgora.membershipExpiresIn(1);
            dAgora.isValidMembership(1);
            uint256 renewCost = ((5 ether) * 4);
            dai.approve(address(dAgora), renewCost);
            dAgora.renewMembership(1, 4, address(dai));
            dAgora.membershipExpiresIn(1);
            dAgora.isValidMembership(1);
        vm.stopPrank();
    }

    function testRenewExpiredToken_USDC() public {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + periclesiaPrice;
            usdc.approve(address(dAgora), price);
            dAgora.mintPericlesiaTier(1, address(usdc));
            dAgora.membershipExpiresIn(1);
            dAgora.isValidMembership(1);
            dAgora.checkTokenTier(1);
            vm.warp(2778400);
            dAgora.membershipExpiresIn(1);
            dAgora.isValidMembership(1);
            uint256 renewCost = ((5 ether) * 4);
            usdc.approve(address(dAgora), renewCost);
            dAgora.renewMembership(1, 4, address(usdc));
            dAgora.membershipExpiresIn(1);
            dAgora.isValidMembership(1);
        vm.stopPrank();
    }

    function testFailRenewMembershipNotExpiring() public {
        //User Mint's A Membership
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 4);
            uint256 price = monthlyCost + dagorianPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintdAgoraianTier(4, address(dai));
            dAgora.membershipExpiresIn(1);
            vm.warp(111111);
            dAgora.membershipExpiresIn(1);
            uint256 renewCost = ((5 ether) * 4);
            dai.approve(address(dAgora), renewCost);
            dAgora.renewMembership(1, 4, address(dai));
            dAgora.membershipExpiresIn(1);
        vm.stopPrank();
    }

    function testFailRenewNotTokenOwner() public {
         vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + dagorianPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintdAgoraianTier(1, address(dai));
        vm.stopPrank();
        vm.startPrank(alice);
            uint256 renewCost = ((5 ether) * 4);
            dai.approve(address(dAgora), renewCost);
            dAgora.renewMembership(1, 4, address(dai));
        vm.stopPrank();
    }
}