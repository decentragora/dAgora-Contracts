import { expect } from "chai";
import { assert } from "console";
import { ethers, upgrades} from "hardhat";

describe("Test Membership Upgrade Functions", function () {
    let proxy: any; 
    let proxyAddress: any;
    let DAI: any;
    let dagoraTreasury: any;
    let addr1: any;
    let addr2: any;
    let addr3: any;
    let addr4: any;
    let addrs: any;
    let domain: any;
    let types: any;
    let message: any;
    let deadline: any;
    let implementationAddress: any;
    let startingTimestamp: any;


    beforeEach(async function () {
        const currentBlock = await ethers.provider.getBlockNumber();
        const blockTimestamp = (await ethers.provider.getBlock(currentBlock)).timestamp;
        startingTimestamp= blockTimestamp;
        [dagoraTreasury, addr1, addr2, addr3, addr4, ...addrs] = await ethers.getSigners();

        const membershipV1 = await ethers.getContractFactory("DagoraMembershipsV1");
        proxy = await upgrades.deployProxy(membershipV1, [
            'Dagora Memberships',
            'DAGORA',
            'https://decentragora.xyz/api/tokenid/',
            dagoraTreasury.address,

        ]);
        await proxy.deployed();

        // get implementation address
        implementationAddress = await upgrades.erc1967.getImplementationAddress(proxy.address);
        await proxy.setProxyAddress(proxy.address);
        

        ///Toggle Paused on Proxy membership state
        await proxy.connect(dagoraTreasury).togglePaused();

    });

    it("Should Upgrade from ecclesia tier to dagora tier", async function () {  
        await proxy.connect(addr1).freeMint();
        const membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(0);
        ///Upgrade to dagorian tier

        const price = await proxy._getUpgradePrice(1, 0, 1);
       
        await proxy.connect(addr1).upgradeMembership(1, 0, 1, {value: price});
        const membership2 = await proxy.getMembership(1);
        expect(membership2[0]).to.equal(1);
    });

    it("Should Upgrade from Ecclesia  tier to Hoplite tier", async function () {
        await proxy.connect(addr1).freeMint();
        const membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(0);
        expect(membership[1]).to.equal(addr1.address);
        expect(membership[2]).to.equal(1);
        ///Upgrade to dagorian tier

        const price = await proxy._getUpgradePrice(1, 0, 2);
        await proxy.connect(addr1).upgradeMembership(2, 0, 1, {value: price});
        // const membership2 = await proxy.getMembership(1);
        // expect(membership2[0]).to.equal(2);
    });
    
    it("Should Upgrade from Ecclesia  tier to Perclesian tier", async function () {
        await proxy.connect(addr1).freeMint();
        const membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(0);
        ///Upgrade to dagorian tier

        const price = await proxy._getUpgradePrice(1, 0, 3);
        await proxy.connect(addr1).upgradeMembership(3, 0, 1, {value: price});
        const membership2 = await proxy.getMembership(1);
        expect(membership2[0]).to.equal(3);
    });

    it("Should upgrade from Dagorian tier to Hoplite tier", async function () {
        const price = await proxy.getMintPrice(3, 1);
        await proxy.connect(addr1).mintMembership(1, 3, {value: price});
        const membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(1);

        const price2 = await proxy._getUpgradePrice(1, 1, 2);
        await proxy.connect(addr1).upgradeMembership(2, 1, 1, {value: price2});
        const membership2 = await proxy.getMembership(1);
        expect(membership2[0]).to.equal(2);
    });

    it("Should upgrade from Dagorian tier to Perclesian tier", async function () {
        const price = await proxy.getMintPrice(3, 1);
        await proxy.connect(addr1).mintMembership(1, 3, {value: price});
        const membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(1);

        const price2 = await proxy._getUpgradePrice(1, 1, 3);
        await proxy.connect(addr1).upgradeMembership(3, 1, 1, {value: price2});
        const membership2 = await proxy.getMembership(1);
        expect(membership2[0]).to.equal(3);
    });

    it("Should upgrade from Hoplite tier to Perclesian tier", async function () {
        const price = await proxy.getMintPrice(3, 2);
        await proxy.connect(addr1).mintMembership(2, 3, {value: price});
        const membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(2);
        expect(membership[2]).to.equal(1);

        const price2 = await proxy._getUpgradePrice(1, 2, 3);
        await proxy.connect(addr1).upgradeMembership(3, 2, 1, {value: price2});
        const membership2 = await proxy.getMembership(1);
        expect(membership2[0]).to.equal(3);
    });

    
});

