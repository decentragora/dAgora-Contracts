import { expect } from "chai";
import { assert } from "console";
import { ethers, upgrades} from "hardhat";

describe("Test  Create SimpleNFT Factory", function () {
    let proxy: any;
    let proxyAddress: any;
    let factory: any;
    let factoryAddress: any;
    let factoryProxy: any;
    let factoryProxyAddress: any;
    let simpleNFTA: any;
    let SNFTA: any;
    let DAI: any;
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

        simpleNFTA = await ethers.getContractFactory("SimpleNFTA");

        factory = await ethers.getContractFactory("DagoraSimpleNFTFactory");
        factoryProxy = await upgrades.deployProxy(factory, [
            proxy.address,
        ]);

        await factoryProxy.deployed();
        factoryProxyAddress = factoryProxy.address;
        factoryProxy.togglePaused();

        //Gift membership to addr1
        await proxy.connect(dagoraTreasury).giftMembership(addr1.address, 1, 3);
        expect(await proxy.balanceOf(addr1.address)).to.equal(1);

    });

    it("Should allow Addr1 to create a new NFT Contract", async function () {
        expect(await proxy.ownerOf(1)).to.equal(addr1.address);
        //Create a new NFT Contract
        await factoryProxy.connect(addr1).createSimpleNFTA(
            "TestNFTA",
            "TNFTA",
            "https://dagora.io/nft/",
            10,
            ethers.utils.parseEther("0.1"),
            100,
            addr1.address,
            1
        );
        const deployAddrs = await factoryProxy.userContracts(addr1.address , 0);
        console.log('deployed Address', deployAddrs);
    });

    it("Should set the correct owner of the NFT Contract", async function () {
        expect(await proxy.ownerOf(1)).to.equal(addr1.address);
        //Create a new NFT Contract
        await factoryProxy.connect(addr1).createSimpleNFTA(
            "TestNFTA",
            "TNFTA",
            "https://dagora.io/nft/",
            10,
            ethers.utils.parseEther("0.1"),
            100,
            addr1.address,
            1
        );
        const deployAddrs = await factoryProxy.userContracts(addr1.address , 0);
        const nftContract = await ethers.getContractAt("SimpleNFTA", deployAddrs);
        expect(await nftContract.owner()).to.equal(addr1.address);
    });

    it("Should not allow a non member to create a new NFT Contract", async function () {
        //Create a new NFT Contract
        await expect(factoryProxy.connect(addr2).createSimpleNFTA(
            "TestNFTA",
            "TNFTA",
            "https://dagora.io/nft/",
            10,
            ethers.utils.parseEther("0.1"),
            100,
            addr1.address,
            1
        )).to.be.revertedWithCustomError(
            factoryProxy,
            "DagoraFactory__NotDAgoraMembershipsOwnerOrDelegate"
        );
    });

    it("Should not allow non owner to toggle the paused state of contract", async function () {
        //Create a new NFT Contract
        await expect(factoryProxy.connect(addr2).togglePaused()).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should revert if factory is paused", async function () {
        await factoryProxy.togglePaused();
        //Create a new NFT Contract
        await expect(factoryProxy.connect(addr1).createSimpleNFTA(
            "TestNFTA",
            "TNFTA",
            "https://dagora.io/nft/",
            10,
            ethers.utils.parseEther("0.1"),
            100,
            addr1.address,
            1
        )).to.be.revertedWithCustomError(
            factoryProxy,
            "DagoraFactory__TokenCreationPaused"
        );

    });

    it("Should revert if the factory is re-initialized", async function () {
        await expect(factoryProxy.connect(addr1).initialize(proxy.address)).to.be.revertedWith('Initializable: contract is already initialized')
    });

    it("Should revert if members tier is below the required tier", async function () {
        await factoryProxy.setMinSimpleNFTATier(3);
        //Create a new NFT Contract
        await expect(factoryProxy.connect(addr1).createSimpleNFTA(
            "TestNFTA",
            "TNFTA",
            "https://dagora.io/nft/",
            10,
            ethers.utils.parseEther("0.1"),
            100,
            addr1.address,
            1
        )).to.be.revertedWithCustomError(
            factoryProxy,
            "DagoraFactory__InvalidTier"
        );
    });

    it("Should revert if membership is not valid", async function () {
        let isValid = await proxy.isValidMembership(1);
        expect(isValid).to.equal(true);
        /// Skip ahead 4 months
        await ethers.provider.send("evm_increaseTime", [60 * 60 * 24 * 30 * 4]);
        await ethers.provider.send("evm_mine", []);
        //Create a new NFT Contract
        isValid = await proxy.isValidMembership(1);
        expect(isValid).to.equal(false);
        await expect(factoryProxy.connect(addr1).createSimpleNFTA(
            "TestNFTA",
            "TNFTA",
            "https://dagora.io/nft/",
            10,
            ethers.utils.parseEther("0.1"),
            100,
            addr1.address,
            1
        )).to.be.revertedWithCustomError(
            factoryProxy,
            "DagoraFactory__ExpiredMembership"
        );
        
    });


    
});