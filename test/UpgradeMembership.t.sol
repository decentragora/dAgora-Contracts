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

contract UpgradeMembershipTests is Test {
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

    function testUpgrade_DAgorainTo_Hoplite() public {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + dagorianPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintdAgoraianTier(1, address(dai));
            dAgora.checkTokenTier(1);
            uint256 upgradeCost = hoplitePrice - dagorianPrice;
            dai.approve(address(dAgora), upgradeCost);
            dAgora.upgradeMemebership(1, dAgoraMemberships.Membership(2), address(dai));
            dAgora.checkTokenTier(1);
        vm.stopPrank();
    }

    function testUpgrade_DAgorainTo_Periclesia() public {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + dagorianPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintdAgoraianTier(1, address(dai));
            dAgora.checkTokenTier(1);
            uint256 upgradeCost = (periclesiaPrice + hoplitePrice) - dagorianPrice;
            dai.approve(address(dAgora), upgradeCost);
            dAgora.upgradeMemebership(1, dAgoraMemberships.Membership(3), address(dai));
            dAgora.checkTokenTier(1);
        vm.stopPrank();
    }

    function testUpgradeHoptileTo_Periclesia() public {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + hoplitePrice;
            dai.approve(address(dAgora), price);
            dAgora.mintHoptileTier(1, address(dai));
            dAgora.checkTokenTier(1);
            uint256 upgradeCost = (periclesiaPrice - (dagorianPrice + hoplitePrice));
            dai.approve(address(dAgora), upgradeCost);
            dAgora.upgradeMemebership(1, dAgoraMemberships.Membership(3), address(dai));
            dAgora.checkTokenTier(1);
        vm.stopPrank();       
    }

    function testFailUpgrade_SameTier() public {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + periclesiaPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintPericlesiaTier(1, address(dai));
            dAgora.checkTokenTier(1);
            uint256 upgradeCost = (periclesiaPrice - (dagorianPrice + hoplitePrice));
            dai.approve(address(dAgora), upgradeCost);
            dAgora.upgradeMemebership(1, dAgoraMemberships.Membership(3), address(dai));
            dAgora.checkTokenTier(1);
        vm.stopPrank();   
    }

    function testFailUpgrade_LowerTier() public {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + dagorianPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintdAgoraianTier(1, address(dai));
            dAgora.checkTokenTier(1);
            uint256 upgradeCost = (periclesiaPrice - (dagorianPrice + hoplitePrice));
            dai.approve(address(dAgora), upgradeCost);
            dAgora.upgradeMemebership(1, dAgoraMemberships.Membership(0), address(dai));
            dAgora.checkTokenTier(1);
        vm.stopPrank();   
    }

    function testFailUpgrade_AlreadyHighestTier() public {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + periclesiaPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintPericlesiaTier(1, address(dai));
            dAgora.checkTokenTier(1);
            uint256 upgradeCost = (periclesiaPrice - (dagorianPrice + hoplitePrice));
            dai.approve(address(dAgora), upgradeCost);
            dAgora.upgradeMemebership(1, dAgoraMemberships.Membership(4), address(dai));
            dAgora.checkTokenTier(1);
        vm.stopPrank();   
    }

    function testFailUpgrade_NotEnoughFunds() public payable {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + dagorianPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintdAgoraianTier(1, address(dai));
            dAgora.checkTokenTier(1);
            uint256 upgradeCost = (periclesiaPrice - (dagorianPrice + hoplitePrice));
            dai.approve(address(dAgora), upgradeCost);
            dAgora.upgradeMemebership(1, dAgoraMemberships.Membership(3), address(dai));
            dAgora.checkTokenTier(1);
        vm.stopPrank();   
    }

    function testFailUpgradeNotTokenOwner() public {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + dagorianPrice;
            dai.approve(address(dAgora), price);
            dAgora.mintdAgoraianTier(1, address(dai));
        vm.stopPrank();
        vm.startPrank(alice);
            uint256 upgradeCost = (hoplitePrice - dagorianPrice) + periclesiaPrice;
            dai.approve(address(dAgora), upgradeCost);
            dAgora.upgradeMemebership(1, dAgoraMemberships.Membership(3), address(dai));
        vm.stopPrank();
    }

}