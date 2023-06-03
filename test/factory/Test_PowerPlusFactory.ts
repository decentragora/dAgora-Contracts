import { expect } from "chai";
import { assert } from "console";
import { ethers, upgrades } from "hardhat";
import MerkleTree from "merkletreejs";
import keccak256 from "keccak256";


describe("Test  Create Power Plus Factory", function () {
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
    let addr3: any;
    let addrs: any;
    let leaves: any;
    let tree: any;
    let root: any;
    let deployParams: any;

    

    beforeEach(async function () {
        [dagoraTreasury, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();

        leaves = [
            addr2.address,
            addr3.address,
        ];

        tree = new MerkleTree(leaves, keccak256, {
            hashLeaves: true,
            sortPairs: true,
          });
        root = tree.getHexRoot();    

        const membership = await ethers.getContractFactory("DagoraMembershipsV1");
        proxy = await upgrades.deployProxy(membership, [
            'Dagora Memberships',
            'DAGORA',
            'https://dagora.io/memberships/',
            dagoraTreasury.address
        ]);
        await proxy.deployed();
        proxyAddress = proxy.address;

        simpleNFTA = await ethers.getContractFactory("PowerPlusNFT");

        factory = await ethers.getContractFactory("DagoraPowerPlusNFTFactory");
        factoryProxy = await upgrades.deployProxy(factory, [
            proxy.address,
        ]);

        await factoryProxy.deployed();
        factoryProxyAddress = factoryProxy.address;
        factoryProxy.togglePaused();

        //Gift membership to addr1
        await proxy.connect(dagoraTreasury).giftMembership(addr1.address, 3, 3);
        expect(await proxy.balanceOf(addr1.address)).to.equal(1);

        deployParams = [
            'Power Plus NFT',
            'PPNFT',
            'https://dagora.io/powerplusnft/',
            10,
            5,
            1000, // 10%
            ethers.utils.parseEther('0.1'),
            ethers.utils.parseEther('0.05'),
            100,
            addr1.address,
            addr1.address,
            root,
        ];
    });

    it("Should allow Addr1 to create a new NFT Contract", async function () {
        expect(await proxy.ownerOf(1)).to.equal(addr1.address);
        //Create a new NFT Contract
        await factoryProxy.connect(addr1).createPowerPlusNFT(
            deployParams,
            1
        );
    });

    it("Should set the correct owner of the NFT Contract", async function () {
        expect(await proxy.ownerOf(1)).to.equal(addr1.address);
        //Create a new NFT Contract
        await factoryProxy.connect(addr1).createPowerPlusNFT(
            deployParams,
            1
        );
        const deployAddrs = await factoryProxy.userContracts(addr1.address , 0);
        const nftContract = await ethers.getContractAt("SimpleNFTA", deployAddrs);
        expect(await nftContract.owner()).to.equal(addr1.address);
    });

    it("Should not allow a non member to create a new NFT Contract", async function () {
        //Create a new NFT Contract
        await expect(factoryProxy.connect(addr2).createPowerPlusNFT(
            deployParams,
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
        await expect(factoryProxy.connect(addr1).createPowerPlusNFT(
            deployParams,
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
        // gift membership to addr2
        await proxy.connect(dagoraTreasury).giftMembership(addr2.address, 1, 1);
        //Create a new NFT Contract
        await expect(factoryProxy.connect(addr2).createPowerPlusNFT(
            deployParams,
            2
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
        await expect(factoryProxy.connect(addr1).createPowerPlusNFT(
            deployParams,
            1
        )).to.be.revertedWithCustomError(
            factoryProxy,
            "DagoraFactory__ExpiredMembership"
        );
        
    });
});