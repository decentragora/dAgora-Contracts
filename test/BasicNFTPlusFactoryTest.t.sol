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
import {dAgoraBasicNFTPlusFactory} from "../src/dAgoraFactories/dAgoraBasicNFTPlusFactory.sol";


contract dAgoraBasicNFTPlusFactoryTest is Test {
    address dAgoraTreasury = address(0x1337);
    address signer = address(0x133702);
    address alice = address(0x133703);
    address bob = address(0x133704);
    address chrome = address(0xcb5c05B9916B49adf97cC31a0c7089F3B4Cfa8b1);
    address user1 = address(0x133705);
    address user2 = address(0x133706);
    address user3 = address(0x133707);

    dAgoraMemberships dAgora;
    dAgoraBasicNFTPlusFactory factory;
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

        factory = new dAgoraBasicNFTPlusFactory(address(dAgora));


        vm.stopPrank();

        vm.startPrank(bob);
            dai._mint();
            usdc._mint();
        vm.stopPrank();
    }


    function testCreatedAgoraBasicNFTPlusFactory() public {
        vm.startPrank(bob);
            uint256 monthlyCost = ((5 ether) * 1);
            uint256 price = monthlyCost + hoplitePrice;
            dai.approve(address(dAgora), price);
            dAgora.mintHoptileTier(1,  address(dai));

            //create NFT
            factory.createBasicNFTPlus(
                'TestNFT',
                'TNFT',
                'ipfs://BaseURIOrCID/',
                1 ether,
                10,
                10,
                100,
                address(bob),
                0x0000000000000000000000000000000000000000000000000000000000000000
            );            
        vm.stopPrank();
    }

    function testFailNoMembershipCreateNFT() public {
        vm.startPrank(bob);
            factory.createBasicNFTPlus(
                'TestNFT',
                'TNFT',
                'ipfs://BaseURIOrCID/',
                1 ether,
                10,
                10,
                100,
                address(bob),
                0x0000000000000000000000000000000000000000000000000000000000000000
            );            
        vm.stopPrank();
    }

    function testFailWrongTier() public {
        vm.startPrank(dAgoraTreasury);
            dAgora.giftMembership(address(alice), 1, dAgoraMemberships.Membership(0));
        vm.stopPrank();
        vm.startPrank(alice);
            factory.createBasicNFTPlus(
                'TestNFT',
                'TNFT',
                'ipfs://BaseURIOrCID/',
                1 ether,
                10,
                10,
                100,
                address(bob),
                0x0000000000000000000000000000000000000000000000000000000000000000
            );            
        vm.stopPrank();
    }

}