import { expect } from "chai";
import { assert } from "console";
import { ethers, upgrades} from "hardhat";

describe("Test Deployment", function () {
    let proxy: any;
    let proxyAddress: any;
    let dagoraTreasury: any;
    let addr1: any;
    let addr2: any;
    let addrs: any;

    beforeEach(async function () {
        [dagoraTreasury, addr1, addr2, ...addrs] = await ethers.getSigners();

        const membership = await ethers.getContractFactory("DagoraMembershipsV1");
        proxy = await upgrades.deployProxy(membership, [
            'Dagora Memberships',
            'DAGORA',
            'https://dagora.io/memberships/',
            dagoraTreasury.address,
        ]);

        await proxy.deployed();
        proxyAddress = proxy.address;

    });

    describe("Deployment", function () {

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

        it("Should set the right treasury address", async function () {
            expect(await proxy.dagoraTreasury()).to.equal(dagoraTreasury.address);
        });

        it("Should set the right totalSupply", async function () {
            expect(await proxy.totalSupply()).to.equal(0);
        });


                    // ecclesiaRenewPrice = 2600000000000000 || 0.0026 ETH;
    // dagorianPrice = 26000000000000000 || 0.026 ETH;
    // dagoraRenewPrice = 2600000000000000 || 0.0026 ETH;
    // hoplitePrice = 42000000000000000 || 0.042 ETH;
    // hopliteRenewPrice = 5200000000000000 || 0.0052 ETH;
    // percelsiaPrice = 520000000000000000 || 0.52 ETH;
    // percelsiaRenewPrice = 26000000000000000 || 0.026 ETH;
    // discount = 2600000000000000 || 0.0026 ETH;
        it("Should Have Right Prices set", async function () {
            expect(await proxy.ecclesiaPrice()).to.equal(0);
            expect(await proxy.ecclesiaRenewPrice()).to.equal(ethers.utils.parseEther('0.0026'));
            expect(await proxy.dagorianPrice()).to.equal(ethers.utils.parseEther('0.026'));
            expect(await proxy.dagoraRenewPrice()).to.equal(ethers.utils.parseEther('0.0026'));
            expect(await proxy.hoplitePrice()).to.equal(ethers.utils.parseEther('0.042'));
            expect(await proxy.hopliteRenewPrice()).to.equal(ethers.utils.parseEther('0.0052'));
            expect(await proxy.percelsiaPrice()).to.equal(ethers.utils.parseEther('0.52'));
            expect(await proxy.percelsiaRenewPrice()).to.equal(ethers.utils.parseEther('0.026'));
            expect(await proxy.discount()).to.equal(ethers.utils.parseEther('0.0026'));
        });

        it("Should not allow another user to initailization", async function () {
            await expect(proxy.initialize(
                'Dagora Memberships',
                'DAGORA',
                'https://dagora.io/memberships/',
                dagoraTreasury.address,
            )).to.be.revertedWith("ERC721A__Initializable: contract is already initialized");
        });

    });

});
