import { expect } from "chai";
import { assert } from "console";
import { ethers, upgrades } from "hardhat";
import MerkleTree from "merkletreejs";
import keccak256 from "keccak256";


describe("Test NFTAPlus", function () {
    let proxy: any;
    let proxyAddress: any;
    let factory: any;
    let factoryAddress: any;
    let factoryProxy: any;
    let factoryProxyAddress: any;
    let NFTAPlus: any;
    let nft: any;
    let Nft: any;
    let deployedAddress: any;
    let DAI: any;
    let dagoraTreasury: any;
    let addr1: any;
    let addr2: any;
    let addr3: any;
    let addr4: any;
    let addrs: any;
    let startTimeStamp: any;
    let leaves: any;
    let tree: any;
    let root: any;


    beforeEach(async function () {
        [dagoraTreasury, addr1, addr2, addr3, addr4, ...addrs] = await ethers.getSigners();
        //Test deadline 
        const deadline = ethers.constants.MaxUint256;

        /// Setup merkle tree with 2 addresses
        leaves = [
            addr2.address,
            addr3.address,
        ];

        tree = new MerkleTree(leaves, keccak256, {
            hashLeaves: true,
            sortPairs: true,
          });
        root = tree.getHexRoot();            
        // Get starting timestamp
        startTimeStamp = Math.floor(Date.now() / 1000);
        //Deploy DAI
        const Dai = await ethers.getContractFactory("Dai");
        DAI = await Dai.deploy();
        await DAI.deployed();

        //Deploy Membership Proxy
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

        NFTAPlus = await ethers.getContractFactory("NFTAPlus");

        //Deploy Factory Proxy
        const factory = await ethers.getContractFactory("DagoraNFTAPlusFactory");
        factoryProxy = await upgrades.deployProxy(factory, [
            proxy.address
        ]);
        await factoryProxy.deployed();
        await factoryProxy.togglePaused();
        //mint dai for addr1
        await DAI.mint();
        await DAI.connect(addr1).mint();
        await DAI.connect(addr2).mint();
        // Gift membership to addr1 for 3 months
        await proxy.connect(dagoraTreasury).giftMembership(addr1.address, 1, 3);
        expect(await proxy.ownerOf(1)).to.equal(addr1.address);
        let _membership = await proxy.getMembership(1);
        expect(_membership[0]).to.equal(1);
        expect(_membership[1]).to.equal(addr1.address);
        expect(_membership[2]).to.equal(1);

        const tx = await factoryProxy.connect(addr1).createNFTAPlus(
            "NFTAPlus",
            "NFTA+",
            "https://test.io/nft/",
            10,
            5,
            ethers.utils.parseEther("0.1"),
            ethers.utils.parseEther("0.05"),
            100,
            addr1.address,
            root,
            1
        );
        
        const receipt = await tx.wait();
        const nftAddress = await factoryProxy.getUserContracts(addr1.address);
        assert(nftAddress != factoryAddress, "NFT Address is the same as the factory address");
        assert(nftAddress != proxyAddress, "NFT Address is the same as the proxy address");
        assert(nftAddress != dagoraTreasury.address, "NFT Address is the same as the treasury address");
        assert(nftAddress != addr1.address, "NFT Address is the same as the addr1 address");
        assert(nftAddress != NFTAPlus.address, "NFT Address is the same as the NFTAPlus address");
        nft = NFTAPlus.attach(nftAddress[0]);
        deployedAddress = nftAddress[0];
        const name = await nft.name();
        const symbol = await nft.symbol();
        const uri = await nft.baseURI();
        const bulkBuyLimit = await nft.bulkBuyLimit();
        const maxAllowListAmount = await nft.maxAllowListAmount();
        const price = await nft.mintPrice();
        const prealsePrice = await nft.presaleMintPrice();
        const maxSupply = await nft.maxSupply();
        const owner = await nft.owner();
        const _root = await nft.merkleRoot();

        expect(name).to.equal("NFTAPlus");
        expect(symbol).to.equal("NFTA+");
        expect(uri).to.equal("https://test.io/nft/");
        expect(bulkBuyLimit).to.equal(10);
        expect(maxAllowListAmount).to.equal(5);
        expect(price).to.equal(ethers.utils.parseEther("0.1"));
        expect(prealsePrice).to.equal(ethers.utils.parseEther("0.05"));
        expect(maxSupply).to.equal(100);
        expect(owner).to.equal(addr1.address);
        expect(_root).to.equal(root);
    });
        // Mint functions
        it("Should Allow addr1 to Mint to bulkbuylimit", async function () {
            await nft.connect(addr1).togglePresale();
            const limit = await nft.bulkBuyLimit();
            const mintCost = await nft.mintPrice();
            await nft.connect(addr2).mintNFT(addr2.address, limit, { value: mintCost.mul(limit) });
            expect(await nft.balanceOf(addr2.address)).to.equal(limit);
            expect(await nft.totalSupply()).to.equal(limit);
            const balanceOfContract = await ethers.provider.getBalance(nft.address);
            expect(balanceOfContract).to.equal(mintCost.mul(limit));
        });

        it("Should not Allow addr1 to Mint to over bulkbuylimit", async function () {
            await nft.connect(addr1).togglePresale();
            const limit = await nft.bulkBuyLimit();
            const mintCost = await nft.mintPrice();
            await expect(nft.connect(addr2).mintNFT(addr2.address, limit + 1, { value: mintCost.mul(limit + 1) })).to.be.revertedWith("Exceeds bulk buy limit");
        });

        it("Should Allow a allowlisted address to Mint during presale", async function () {
            const limit = await nft.maxAllowListAmount();
            const mintCost = await nft.presaleMintPrice();
            const leaf = keccak256(leaves[0]);
            const proof = tree.getHexProof(leaf);
            const cost = mintCost.mul(limit);
            await nft.connect(addr2).presaleMintNFT(proof, limit, { value: cost});
            expect(await nft.balanceOf(addr2.address)).to.equal(limit);
            expect(await nft.totalSupply()).to.equal(limit);
            const balanceOfContract = await ethers.provider.getBalance(nft.address);
            expect(balanceOfContract).to.equal(cost);
        });

        it("Should not Allow a non-allowlisted address to Mint during presale", async function () {
            const limit = await nft.maxAllowListAmount();
            const mintCost = await nft.presaleMintPrice();
            const proof = tree.getHexProof(leaves[1]);
            const cost = mintCost.mul(limit);
            await expect(nft.connect(addr4).presaleMintNFT(proof, limit, { value: cost})).to.be.revertedWith("Invalid merkle proof");
            expect(await nft.balanceOf(addr3.address)).to.equal(0);
            expect(await nft.totalSupply()).to.equal(0);
        });

        it("Should not Allow a allowlisted address to Mint over maxAllowListAmount during presale even if transferred", async function () {
            const limit = await nft.maxAllowListAmount();
            const mintCost = await nft.presaleMintPrice();
            const leaf = keccak256(leaves[0]);
            const proof = tree.getHexProof(leaf);
            const cost = mintCost.mul(limit);
            await nft.connect(addr2).presaleMintNFT(proof, limit, { value: cost});
            expect(await nft.balanceOf(addr2.address)).to.equal(limit);
            expect(await nft.totalSupply()).to.equal(limit);
            const balanceOfContract = await ethers.provider.getBalance(nft.address);
            expect(balanceOfContract).to.equal(cost);

            await nft.connect(addr2).transferFrom(addr2.address, addr3.address, 1);
            expect(await nft.balanceOf(addr2.address)).to.equal(limit - 1);
            expect(await nft.balanceOf(addr3.address)).to.equal(1);
            expect(await nft.totalSupply()).to.equal(limit);
            await expect(nft.connect(addr2).presaleMintNFT(proof, 1, { value: mintCost})).to.be.revertedWith("Amount exceeds max allowList amount");
        });

        it("Should Allow Owner of NFTAPlus to Set Base URI", async function () {
            expect(await nft.baseURI()).to.equal("https://test.io/nft/");
            await nft.connect(addr1).setBaseURI("https://Test.com/nft/V2/");
            expect(await nft.baseURI()).to.equal("https://Test.com/nft/V2/");
        });

        it("Should not Allow Non-Owner of NFTAPlus to Set Base URI", async function () {
            expect(await nft.baseURI()).to.equal("https://test.io/nft/");
            await expect(nft.connect(addr2).setBaseURI("https://Test.com/nft/V2/")).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.baseURI()).to.equal("https://test.io/nft/");
        });

        it("Should Allow Owner of NFTAPlus to Set the Base Extension URI", async function () {
            expect(await nft.baseExtension()).to.equal(".json");
            await nft.connect(addr1).setBaseExtension(".png");
            expect(await nft.baseExtension()).to.equal(".png");
        });

        it("Should not Allow Non-Owner of NFTAPlus to Set the Base Extension URI", async function () {
            expect(await nft.baseExtension()).to.equal(".json");
            await expect(nft.connect(addr2).setBaseExtension(".png")).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.baseExtension()).to.equal(".json");
        });
    
        it("Should Allow Owner of SimpleNFTA to Set the Mint Price", async function () {
            expect(await nft.mintPrice()).to.equal(ethers.utils.parseEther("0.1"));
            await nft.connect(addr1).setMintPrice(ethers.utils.parseEther("0.2"));
            expect(await nft.mintPrice()).to.equal(ethers.utils.parseEther("0.2"));
        });
    
        it("Should not Allow Non-Owner of SimpleNFTA to Set the Mint Price", async function () {
            expect(await nft.mintPrice()).to.equal(ethers.utils.parseEther("0.1"));
            await expect(nft.connect(addr2).setMintPrice(ethers.utils.parseEther("0.2"))).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.mintPrice()).to.equal(ethers.utils.parseEther("0.1"));
        });

        it("Should Allow Owner of SimpleNFTA to Set the Presale Mint Price", async function () {
            expect(await nft.presaleMintPrice()).to.equal(ethers.utils.parseEther("0.05"));
            await nft.connect(addr1).setPresaleMintPrice(ethers.utils.parseEther("0.1"));
            expect(await nft.presaleMintPrice()).to.equal(ethers.utils.parseEther("0.1"));
        });

        it("Should not Allow Non-Owner of SimpleNFTA to Set the Presale Mint Price", async function () {
            expect(await nft.presaleMintPrice()).to.equal(ethers.utils.parseEther("0.05"));
            await expect(nft.connect(addr2).setPresaleMintPrice(ethers.utils.parseEther("0.1"))).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.presaleMintPrice()).to.equal(ethers.utils.parseEther("0.05"));
        });
    
        it("Should Allow Owner of SimpleNFTA to Set the Bulk buy limit", async function () {
            expect(await nft.bulkBuyLimit()).to.equal(10);
            await nft.connect(addr1).setBulkBuyLimit(20);
            expect(await nft.bulkBuyLimit()).to.equal(20);
        });
    
        it("Should not Allow Non-Owner of SimpleNFTA to Set the Bulk buy limit", async function () {
            expect(await nft.bulkBuyLimit()).to.equal(10);
            await expect(nft.connect(addr2).setBulkBuyLimit(20)).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.bulkBuyLimit()).to.equal(10);
        });
    
        it("Should Allow Owner of SimpleNFTA to Set the Max Allow List Amount", async function () {
            expect(await nft.maxAllowListAmount()).to.equal(5);
            await nft.connect(addr1).setMaxAllowListAmount(10);
            expect(await nft.maxAllowListAmount()).to.equal(10);
        });

        it("Should not Allow Non-Owner of SimpleNFTA to Set the Max Allow List Amount", async function () {
            expect(await nft.maxAllowListAmount()).to.equal(5);
            await expect(nft.connect(addr2).setMaxAllowListAmount(10)).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.maxAllowListAmount()).to.equal(5);
        });

        it("Should Allow Owner of SimpleNFTA to toggle paused", async function () {
            expect(await nft.isPaused()).to.equal(false);
            await nft.connect(addr1).togglePaused();
            expect(await nft.isPaused()).to.equal(true);
            await nft.connect(addr1).togglePaused();
            expect(await nft.isPaused()).to.equal(false);
        });
    
        it("Should not Allow Non-Owner of SimpleNFTA to toggle paused", async function () {
            expect(await nft.isPaused()).to.equal(false);
            await expect(nft.connect(addr2).togglePaused()).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.isPaused()).to.equal(false);
        });

        it("Should Allow Owner of SimpleNFTA to toggle presale", async function () {
            expect(await nft.isPresale()).to.equal(true);
            await nft.connect(addr1).togglePresale();
            expect(await nft.isPresale()).to.equal(false);
            await nft.connect(addr1).togglePresale();
            expect(await nft.isPresale()).to.equal(true);
        });

        it("Should not Allow Non-Owner of SimpleNFTA to toggle presale", async function () {
            expect(await nft.isPresale()).to.equal(true);
            await expect(nft.connect(addr2).togglePresale()).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.isPresale()).to.equal(true);
        });
    
        it("Should Allow Owner of SimpleNFTA to withdraw ETH", async function () {
            await nft.connect(addr1).togglePresale();
            const balanceBefore = await ethers.provider.getBalance(addr1.address);
            const mintCost = await nft.mintPrice();
            expect(nft.address == deployedAddress, "NFT Address is not the same as the deployed address");
            await nft.connect(addr2).mintNFT(addr2.address, 1, { value: mintCost });
            expect(await nft.balanceOf(addr2.address)).to.equal(1);
            const balanceOfContract = await ethers.provider.getBalance(nft.address);
            expect(balanceOfContract).to.equal(mintCost);
            // Withdraw ETH
            const tx = await nft.connect(addr1).withdrawETH();
            //get gas cost of tx
            const gasCost = await tx.wait().then((receipt: any) => {
                return receipt.gasUsed.mul(tx.gasPrice);
            });
            const balanceAfter = await ethers.provider.getBalance(addr1.address);
            expect(balanceAfter > balanceBefore, "Balance after is not less than balance before");
            expect(balanceAfter).to.equal(balanceBefore.add(mintCost).sub(gasCost));
            const balanceOfContractAfter = await ethers.provider.getBalance(nft.address);
            expect(balanceOfContractAfter).to.equal(0);
        });
        
        it("Should not Allow Non-Owner of SimpleNFTA to withdraw ETH", async function () {
            await nft.connect(addr1).togglePresale();
            const balanceBefore = await ethers.provider.getBalance(addr1.address);
            const mintCost = await nft.mintPrice();
            expect(nft.address == deployedAddress, "NFT Address is not the same as the deployed address");
            await nft.connect(addr2).mintNFT(addr2.address, 1, { value: mintCost });
            expect(await nft.balanceOf(addr2.address)).to.equal(1);
            const balanceOfContract = await ethers.provider.getBalance(nft.address);
            expect(balanceOfContract).to.equal(mintCost);
            // Withdraw ETH
            await expect(nft.connect(addr2).withdrawETH()).to.be.revertedWith("Ownable: caller is not the owner");
            const balanceAfter = await ethers.provider.getBalance(addr1.address);
            expect(balanceAfter).to.equal(balanceBefore);
            const balanceOfContractAfter = await ethers.provider.getBalance(nft.address);
            expect(balanceOfContractAfter).to.equal(mintCost);
        });
    
        it("Should Allow Owner of SimpleNFTA to withdraw ERC20", async function () {
            /// send DAI to contract
            const startingDAiBalance = await DAI.balanceOf(addr1.address);
            await DAI.connect(addr2).transfer(nft.address, ethers.utils.parseEther("100"));
            expect(await DAI.balanceOf(nft.address)).to.equal(ethers.utils.parseEther("100"));
    
            // Withdraw DAI
            await nft.connect(addr1).withdrawERC20(DAI.address);
            expect(await DAI.balanceOf(nft.address)).to.equal(0);
            expect(await DAI.balanceOf(addr1.address)).to.equal(startingDAiBalance.add(ethers.utils.parseEther("100")));
        
        });
    
        it("Should not Allow Non-Owner of SimpleNFTA to withdraw ERC20", async function () {
            /// send DAI to contract
            const startingDAiBalance = await DAI.balanceOf(addr1.address);
            await DAI.connect(addr2).transfer(nft.address, ethers.utils.parseEther("100"));
            expect(await DAI.balanceOf(nft.address)).to.equal(ethers.utils.parseEther("100"));
    
            // Withdraw DAI
            await expect(nft.connect(addr2).withdrawERC20(DAI.address)).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await DAI.balanceOf(nft.address)).to.equal(ethers.utils.parseEther("100"));
            expect(await DAI.balanceOf(addr1.address)).to.equal(startingDAiBalance);
        });

        it("Should revert if there are no ERC20 tokens to withdraw", async function () {
            await expect(nft.connect(addr1).withdrawERC20(DAI.address)).to.be.revertedWith("No tokens to withdraw");
        });
    
        it("Should Allow Owner of SimpleNFTA to reserve tokens", async function () {
            await nft.connect(addr1).reserveTokens(5)
            expect(await nft.balanceOf(addr1.address)).to.equal(5);
            expect(await nft.totalSupply()).to.equal(5);
        });
    
        it("Should not Allow Non-Owner of SimpleNFTA to reserve tokens", async function () {
            await expect(nft.connect(addr2).reserveTokens(5)).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.balanceOf(addr1.address)).to.equal(0);
            expect(await nft.totalSupply()).to.equal(0);
        });
    
        it("Should Return the correct Token URI", async function () {
            await nft.connect(addr1).reserveTokens(1)
            expect(await nft.tokenURI(1)).to.equal("https://test.io/nft/1.json");
        });

        it("Should return the correct type of NFT", async function () {
            expect(await nft.typeOf()).to.equal("dAgora NFTAPlus");
        });

        it("Should not allow non Owner to toggle paused on the factory contract", async function () {
            await expect(factoryProxy.connect(addr2).togglePaused()).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await factoryProxy.isPaused()).to.equal(false);
        });

        it("Should allow owner to set min tier to create contract", async function (){
            expect(await factoryProxy.minNFTAPlusTier()).to.equal(1);
            await factoryProxy.connect(dagoraTreasury).setMinNFTAPlusTier(2);
            expect(await factoryProxy.minNFTAPlusTier()).to.equal(2);
        }); 
    
        it("Should not allow non-Owner to set min tier to create contract", async function (){
            expect(await factoryProxy.minNFTAPlusTier()).to.equal(1);
            await expect(factoryProxy.connect(addr2).setMinNFTAPlusTier(2)).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await factoryProxy.minNFTAPlusTier()).to.equal(1);
        });

        it("Should not allow to query a tokenId that does not exist", async function (){
            await expect(nft.tokenURI(1)).to.be.revertedWith("Token does not exist");
        });

        it("should not allow owner to mint over bulk mint limit", async function (){
            await expect(nft.connect(addr1).reserveTokens(100)).to.be.revertedWith("Exceeds bulk buy limit");
        });

        it("should not allow owner to mint over max supply", async function (){
            // mint full supply
            for (let i = 0; i < 10; i++) {
                await nft.connect(addr1).reserveTokens(10);
            }

            await expect(nft.connect(addr1).reserveTokens(1)).to.be.revertedWith("Exceeds max supply");
        });

        it("Should fail mint if contract is paused", async function () {
            await nft.connect(addr1).togglePaused();
            const limit = await nft.maxAllowListAmount();
            const presaleMintCost = await nft.presaleMintPrice();
            const mintCost = await nft.mintPrice();
            const leaf = keccak256(leaves[0]);
            const proof = tree.getHexProof(leaf);
            const cost = mintCost.mul(limit);
            await expect(nft.connect(addr2).presaleMintNFT(proof, 1, { value: presaleMintCost })).to.be.revertedWith("Contract is paused");
            await nft.connect(addr1).togglePresale();
            await expect(nft.connect(addr2).mintNFT(addr2.address, 1, { value: cost })).to.be.revertedWith("Contract is paused");
        });

        it("Should enforce max supply", async function () {
            for (let i = 0; i < 10; i++) {
                await nft.connect(addr1).reserveTokens(10);
            }
            const limit = await nft.maxAllowListAmount();
            const mintCost = await nft.presaleMintPrice();
            const leaf = keccak256(leaves[0]);
            const proof = tree.getHexProof(leaf); 
            const cost = mintCost.mul(limit);
            await expect(nft.connect(addr2).presaleMintNFT(proof, 1, { value: cost })).to.be.revertedWith("Amount exceeds max supply");
            await nft.connect(addr1).togglePresale();
            await expect(nft.connect(addr2).mintNFT(addr2.address, 1, { value: cost })).to.be.revertedWith("Amount exceeds max supply");
        });

        it("Should revert if not enough funds are sent", async function () {
            const limit = await nft.maxAllowListAmount();
            const mintCost = await nft.presaleMintPrice();
            const leaf = keccak256(leaves[0]);
            const proof = tree.getHexProof(leaf);
            const cost = mintCost.mul(limit);
            await expect(nft.connect(addr2).presaleMintNFT(proof, 1, { value: cost.sub(1) })).to.be.revertedWith("Incorrect amount of ETH sent");
            await nft.connect(addr1).togglePresale();
            await expect(nft.connect(addr2).mintNFT(addr2.address, 1, { value: cost.sub(1) })).to.be.revertedWith("Incorrect amount of ETH sent");
        });

        it("Should revert Public mint during presale", async function () {
            const limit = await nft.maxAllowListAmount();
            const mintCost = await nft.presaleMintPrice();
            const cost = mintCost.mul(limit);
            await expect(nft.connect(addr2).mintNFT(addr2.address, 1, { value: cost })).to.be.revertedWith("Contract is not in public sale");
        });

        it("Should revert if presale mint is called during public sale", async function () {
            await nft.connect(addr1).togglePresale();
            const limit = 1;
            const mintCost = await nft.mintPrice();
            const cost = mintCost.mul(limit);
            await expect(nft.connect(addr2).presaleMintNFT([], 1, { value: cost })).to.be.revertedWith("Contract is not in presale");
        });
});