import { expect } from "chai";
import { assert } from "console";
import { ethers, upgrades} from "hardhat";

describe("Test Deployment", function () {
    let proxy: any;
    let proxyAddress: any;
    let DAI: any;
    let dagoraTreasury: any;
    let addr1: any;
    let addr2: any;
    let addrs: any;

    beforeEach(async function () {
        [dagoraTreasury, addr1, addr2, ...addrs] = await ethers.getSigners();
        const Dai = await ethers.getContractFactory("Dai");
        DAI = await Dai.deploy();
        await DAI.deployed();

        const membership = await ethers.getContractFactory("DagoraMembershipsV1");
        proxy = await upgrades.deployProxy(membership, [
            'Dagora Memberships',
            'DAGORA',
            'https://dagora.io/memberships/',
            dagoraTreasury.address,
            DAI.address
        ]);

        await proxy.deployed();
        proxyAddress = proxy.address;

        //mint dai for addr1
        await DAI.mint();
        DAI.connect(addr1).mint();

    });

    describe("Deployment", function () {
        it("Addr1 should have 10000 dai", async function () {
            expect(await DAI.balanceOf(addr1.address)).to.equal(ethers.utils.parseEther('10000'));
        });

        it("Should set the right owner", async function () {
            expect(await proxy.owner()).to.equal(dagoraTreasury.address);
        });

        it("Should set the right name", async function () {
            expect(await proxy.name()).to.equal('Dagora Memberships');
        });

        it("Should set the right symbol", async function () {
            expect(await proxy.symbol()).to.equal('DAGORA');
        });

        it("Should set the right baseURI", async function () {
            expect(await proxy.baseURI()).to.equal('https://dagora.io/memberships/');
        });

        it("Should set the right DAI address", async function () {
            expect(await proxy.DAI()).to.equal(DAI.address);
        });

        it("Should set the right treasury address", async function () {
            expect(await proxy.dagoraTreasury()).to.equal(dagoraTreasury.address);
        });

        it("Should set the right totalSupply", async function () {
            expect(await proxy.totalSupply()).to.equal(0);
        });

        it("Should Have Right Prices set", async function () {
            expect(await proxy.ecclesiaPrice()).to.equal(ethers.utils.parseEther('0'));
            expect(await proxy.ecclesiaRenewPrice()).to.equal(ethers.utils.parseEther('5'));
            expect(await proxy.dagorianPrice()).to.equal(ethers.utils.parseEther('50'));
            expect(await proxy.dagoraRenewPrice()).to.equal(ethers.utils.parseEther('5'));
            expect(await proxy.hoplitePrice()).to.equal(ethers.utils.parseEther('80'));
            expect(await proxy.hopliteRenewPrice()).to.equal(ethers.utils.parseEther('10'));
            expect(await proxy.percelsiaPrice()).to.equal(ethers.utils.parseEther('1000'));
            expect(await proxy.percelsiaRenewPrice()).to.equal(ethers.utils.parseEther('50'));
            expect(await proxy.discount()).to.equal(ethers.utils.parseEther('5'));
        });

        it("Should not allow another user to initailization", async function () {
            await expect(proxy.initialize(
                'Dagora Memberships',
                'DAGORA',
                'https://dagora.io/memberships/',
                dagoraTreasury.address,
                DAI.address
            )).to.be.revertedWith("ERC721A__Initializable: contract is already initialized");
        });

    });

});
