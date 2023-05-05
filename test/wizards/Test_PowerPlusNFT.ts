import { expect } from "chai";
import { assert } from "console";
import { ethers, upgrades } from "hardhat";
import MerkleTree from "merkletreejs";
import keccak256 from "keccak256";

describe("Test Power Plus NFT", function () {
    let proxy: any;
    let proxyAddress: any;
    let factory: any;
    let factoryAddress: any;
    let factoryProxy: any;
    let factoryProxyAddress: any;
    let PowerPlusNFT: any;
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
    let newRoot: any;
    
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

        PowerPlusNFT = await ethers.getContractFactory("PowerPlusNFT");

        const factory = await ethers.getContractFactory("DagoraPowerPlusNFTFactory");
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
        await proxy.connect(dagoraTreasury).giftMembership(addr1.address, 2, 3);
        expect(await proxy.ownerOf(1)).to.equal(addr1.address);
        let _membership = await proxy.getMembership(1);
        expect(_membership[0]).to.equal(2);
        expect(_membership[1]).to.equal(addr1.address);
        expect(_membership[2]).to.equal(1);

        const deployParams = [
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
            root
        ];

        // Deploy NFT
        const tx = await factoryProxy.connect(addr1).createPowerPlusNFT(deployParams, 1 /* tokenId */);
        const receipt = await tx.wait();
        const nftAddress = await factoryProxy.getUserContracts(addr1.address);
        assert(nftAddress != factoryAddress, "NFT Address is the same as the factory address");
        assert(nftAddress != proxyAddress, "NFT Address is the same as the proxy address");
        assert(nftAddress != dagoraTreasury.address, "NFT Address is the same as the treasury address");
        assert(nftAddress != addr1.address, "NFT Address is the same as the addr1 address");
        nft = PowerPlusNFT.attach(nftAddress[0]);
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
        const royalty = await nft.royaltyInfo(1, ethers.utils.parseEther('1'));
        
        expect(royalty[0]).to.equal(addr1.address);
        expect(royalty[1]).to.equal(ethers.utils.parseEther('0.1'));
        expect(name).to.equal("Power Plus NFT");
        expect(symbol).to.equal("PPNFT");
        expect(uri).to.equal("https://dagora.io/powerplusnft/");
        expect(bulkBuyLimit).to.equal(10);
        expect(maxAllowListAmount).to.equal(5);
        expect(price).to.equal(ethers.utils.parseEther('0.1'));
        expect(prealsePrice).to.equal(ethers.utils.parseEther('0.05'));
        expect(maxSupply).to.equal(100);
        expect(owner).to.equal(addr1.address);
        expect(_root).to.equal(root);
    });


        it("Should have the correct Name and Symbol", async function () {
            expect(await proxy.name()).to.equal("Dagora Memberships");
            expect(await proxy.symbol()).to.equal("DAGORA");
            expect(await nft.name()).to.equal("Power Plus NFT");
            expect(await nft.symbol()).to.equal("PPNFT");
        });

        // Mint functions
        it("Should Allow addr2 to Mint to bulkbuylimit", async function () {
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
            nft.connect(addr1).togglePresale();
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

        it("Should Allow Owner of PowerPlus Contract to Set Base URI", async function () {
            expect(await nft.baseURI()).to.equal("https://dagora.io/powerplusnft/");
            await nft.connect(addr1).setBaseURI("https://Test.com/nft/V2/");
            expect(await nft.baseURI()).to.equal("https://Test.com/nft/V2/");
        });

        it("Should not Allow Non-Owner of PowerPlus Contracct to Set Base URI", async function () {
            expect(await nft.baseURI()).to.equal("https://dagora.io/powerplusnft/");
            await expect(nft.connect(addr2).setBaseURI("https://Test.com/nft/V2/")).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.baseURI()).to.equal("https://dagora.io/powerplusnft/");
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
    
        it("Should Allow Owner of Power Plus NFTA to Set the Mint Price", async function () {
            expect(await nft.mintPrice()).to.equal(ethers.utils.parseEther("0.1"));
            await nft.connect(addr1).setMintPrice(ethers.utils.parseEther("0.2"));
            expect(await nft.mintPrice()).to.equal(ethers.utils.parseEther("0.2"));
        });
    
        it("Should not Allow Non-Owner of Power Plus NFTA to Set the Mint Price", async function () {
            expect(await nft.mintPrice()).to.equal(ethers.utils.parseEther("0.1"));
            await expect(nft.connect(addr2).setMintPrice(ethers.utils.parseEther("0.2"))).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.mintPrice()).to.equal(ethers.utils.parseEther("0.1"));
        });

        it("Should Allow Owner of Power Plus NFTA to Set the Presale Mint Price", async function () {
            expect(await nft.presaleMintPrice()).to.equal(ethers.utils.parseEther("0.05"));
            await nft.connect(addr1).setPresaleMintPrice(ethers.utils.parseEther("0.1"));
            expect(await nft.presaleMintPrice()).to.equal(ethers.utils.parseEther("0.1"));
        });

        it("Should not Allow Non-Owner of Power Plus NFTA to Set the Presale Mint Price", async function () {
            expect(await nft.presaleMintPrice()).to.equal(ethers.utils.parseEther("0.05"));
            await expect(nft.connect(addr2).setPresaleMintPrice(ethers.utils.parseEther("0.1"))).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.presaleMintPrice()).to.equal(ethers.utils.parseEther("0.05"));
        });
    
        it("Should Allow Owner of Power Plus NFTA to Set the Bulk buy limit", async function () {
            expect(await nft.bulkBuyLimit()).to.equal(10);
            await nft.connect(addr1).setBulkBuyLimit(20);
            expect(await nft.bulkBuyLimit()).to.equal(20);
        });
    
        it("Should not Allow Non-Owner of Power Plus NFTA to Set the Bulk buy limit", async function () {
            expect(await nft.bulkBuyLimit()).to.equal(10);
            await expect(nft.connect(addr2).setBulkBuyLimit(20)).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.bulkBuyLimit()).to.equal(10);
        });
    
        it("Should Allow Owner of Power Plus NFTA to Set the Max Allow List Amount", async function () {
            expect(await nft.maxAllowListAmount()).to.equal(5);
            await nft.connect(addr1).setMaxAllowListAmount(10);
            expect(await nft.maxAllowListAmount()).to.equal(10);
        });

        it("Should not Allow Non-Owner of Power Plus NFTA to Set the Max Allow List Amount", async function () {
            expect(await nft.maxAllowListAmount()).to.equal(5);
            await expect(nft.connect(addr2).setMaxAllowListAmount(10)).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.maxAllowListAmount()).to.equal(5);
        });

        it("Should Allow Owner of Power Plus NFTA to toggle paused", async function () {
            expect(await nft.isPaused()).to.equal(false);
            await nft.connect(addr1).togglePaused();
            expect(await nft.isPaused()).to.equal(true);
            await nft.connect(addr1).togglePaused();
            expect(await nft.isPaused()).to.equal(false);
        });
    
        it("Should not Allow Non-Owner of Power Plus NFTA to toggle paused", async function () {
            expect(await nft.isPaused()).to.equal(false);
            await expect(nft.connect(addr2).togglePaused()).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.isPaused()).to.equal(false);
        });

        it("Should Allow Owner of Power Plus NFTA to toggle presale", async function () {
            expect(await nft.preSaleActive()).to.equal(true);
            await nft.connect(addr1).togglePresale();
            expect(await nft.preSaleActive()).to.equal(false);
            await nft.connect(addr1).togglePresale();
            expect(await nft.preSaleActive()).to.equal(true);
        });

        it("Should not Allow Non-Owner of Power Plus NFTA to toggle presale", async function () {
            expect(await nft.preSaleActive()).to.equal(true);
            await expect(nft.connect(addr2).togglePresale()).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.preSaleActive()).to.equal(true);
        });
    
        it("Should Allow Owner of Power Plus NFTA to withdraw ETH", async function () {
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
        
        it("Should not Allow Non-Owner of Power Plus NFTA to withdraw ETH", async function () {
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
    
        it("Should Allow Owner of Power Plus NFTA to withdraw ERC20", async function () {
            /// send DAI to contract
            const startingDAiBalance = await DAI.balanceOf(addr1.address);
            await DAI.connect(addr2).transfer(nft.address, ethers.utils.parseEther("100"));
            expect(await DAI.balanceOf(nft.address)).to.equal(ethers.utils.parseEther("100"));
    
            // Withdraw DAI
            await nft.connect(addr1).withdrawERC20(DAI.address);
            expect(await DAI.balanceOf(nft.address)).to.equal(0);
            expect(await DAI.balanceOf(addr1.address)).to.equal(startingDAiBalance.add(ethers.utils.parseEther("100")));
        
        });
    
        it("Should not Allow Non-Owner of Power Plus NFTA to withdraw ERC20", async function () {
            /// send DAI to contract
            const startingDAiBalance = await DAI.balanceOf(addr1.address);
            await DAI.connect(addr2).transfer(nft.address, ethers.utils.parseEther("100"));
            expect(await DAI.balanceOf(nft.address)).to.equal(ethers.utils.parseEther("100"));
    
            // Withdraw DAI
            await expect(nft.connect(addr2).withdrawERC20(DAI.address)).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await DAI.balanceOf(nft.address)).to.equal(ethers.utils.parseEther("100"));
            expect(await DAI.balanceOf(addr1.address)).to.equal(startingDAiBalance);
        });
    
        it("Should Allow Owner of Power Plus NFTA to reserve tokens", async function () {
            await nft.connect(addr1).reserveTokens(5)
            expect(await nft.balanceOf(addr1.address)).to.equal(5);
            expect(await nft.totalSupply()).to.equal(5);
        });

        it("Should not Allow Owner of Power Plus NFTA to reserve tokens if paused", async function () {
            await nft.connect(addr1).togglePaused();
            await expect(nft.connect(addr1).reserveTokens(5)).to.be.revertedWith("Contract is paused");
            expect(await nft.balanceOf(addr1.address)).to.equal(0);
            expect(await nft.totalSupply()).to.equal(0);
        });
    
        it("Should not Allow Non-Owner of Power Plus NFTA to reserve tokens", async function () {
            await expect(nft.connect(addr2).reserveTokens(5)).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.balanceOf(addr1.address)).to.equal(0);
            expect(await nft.totalSupply()).to.equal(0);
        });
    
        it("Should Return the correct Token URI", async function () {
            await nft.connect(addr1).reserveTokens(1)
            expect(await nft.tokenURI(1)).to.equal("https://dagora.io/powerplusnft/1.json");
        });

        it("Should return the correct type of NFT", async function () {
            expect(await nft.typeOf()).to.equal("dAgora PowerPlusNFT");
        });

        it("Should not allow non Owner to toggle paused on the factory contract", async function () {
            await expect(factoryProxy.connect(addr2).togglePaused()).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await factoryProxy.isPaused()).to.equal(false);
        });

        it("Should allow owner to set new merkleRoot", async function () {
            leaves = [
                addr1.address,
                addr2.address,
                addr3.address,
            ]
            tree = new MerkleTree(leaves, keccak256, {
                hashLeaves: true,
                sortPairs: true,
              });
            root = tree.getHexRoot();     
            
            await nft.connect(addr1).setMerkleRoot(root);
            expect(await nft.merkleRoot()).to.equal(root);
        });

        it("Should not allow non owner to set new merkleRoot", async function () {
            leaves = [
                addr1.address,
                addr2.address,
                addr3.address,
            ]
            tree = new MerkleTree(leaves, keccak256, {
                hashLeaves: true,
                sortPairs: true,
              });
            root = tree.getHexRoot();     
            
            await expect(nft.connect(addr2).setMerkleRoot(root)).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.merkleRoot()).to.not.equal(root);
        });

        it("Should allow owner to set new royalty addresss and fee", async function () {
            await nft.connect(addr1).setRoyalties(addr2.address, 500);
            const info = await nft.royaltyInfo(1, ethers.utils.parseEther("1"));
            expect(info[0]).to.equal(addr2.address);
            expect(info[1]).to.equal(ethers.utils.parseEther("0.05"));
        });

        it("Should not allow non owner to set new royalty addresss and fee", async function () {
            await expect(nft.connect(addr2).setRoyalties(addr2.address, 500)).to.be.revertedWith("Ownable: caller is not the owner");
            const info = await nft.royaltyInfo(1, ethers.utils.parseEther("1"));
            expect(info[0]).to.equal(addr1.address);
            expect(info[1]).to.equal(ethers.utils.parseEther("0.1"));
        });

        it("Should support Interface 0x80ac58cd", async function () {
            expect(await nft.supportsInterface("0x80ac58cd")).to.equal(true);
            expect(await nft.supportsInterface("0x2a55205a")).to.equal(true);
            expect(await nft.supportsInterface("0x01ffc9a7")).to.equal(true);
            expect(await nft.supportsInterface("0x36372b07")).to.equal(false);
        });

        it("Should allow owner to set min tier to create contract", async function (){
            expect(await factoryProxy.minPowerNFTATier()).to.equal(2);
            await factoryProxy.connect(dagoraTreasury).setMinPowerNFTATier(1);
            expect(await factoryProxy.minPowerNFTATier()).to.equal(1);
        }); 
    
        it("Should not allow non-Owner to set min tier to create contract", async function (){
            expect(await factoryProxy.minPowerNFTATier()).to.equal(2);
            await expect(factoryProxy.connect(addr2).setMinPowerNFTATier(1)).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await factoryProxy.minPowerNFTATier()).to.equal(2);
        });

        it("Should revert mint functions if contract is paused", async function (){
            expect(await nft.isPaused()).to.equal(false);
            await nft.connect(addr1).togglePaused();
            expect(await nft.isPaused()).to.equal(true);
            const leaf = keccak256(leaves[0]);
            const proof = tree.getHexProof(leaf);
            const mintCost = await nft.presaleMintPrice();
            await expect(nft.connect(addr2).presaleMintNFT(proof, 1, { value: mintCost })).to.be.revertedWith("Contract is paused");
            await nft.connect(addr1).togglePresale();
            await expect(nft.connect(addr1).mintNFT(addr1.address, 1)).to.be.revertedWith("Contract is paused");
        });

        it("Revert public sale if in presale", async function (){
            await expect(nft.connect(addr1).mintNFT(addr1.address, 1)).to.be.revertedWith("Presale is active");
        });

        it("Should revert presale function if in public sale", async function (){
            await nft.connect(addr1).togglePresale();
            const leaf = keccak256(leaves[0]);
            const proof = tree.getHexProof(leaf);
            const mintCost = await nft.presaleMintPrice();
            await expect(nft.connect(addr1).presaleMintNFT(proof, 1, { value: mintCost })).to.be.revertedWith("Presale is not active");
        });

        it("Should enforce max supply", async function (){
            for(let i = 0; i < 10; i++){
                await nft.connect(addr1).reserveTokens(10);
            }

            await expect(nft.connect(addr1).reserveTokens(1)).to.be.revertedWith("Amount exceeds max supply");
            const leaf = keccak256(leaves[0]);
            const proof = tree.getHexProof(leaf);
            const mintCost = await nft.presaleMintPrice();
            await expect(nft.connect(addr2).presaleMintNFT(proof, 1, { value: mintCost })).to.be.revertedWith("Amount exceeds max supply");
            await nft.connect(addr1).togglePresale();
            const mintCost2 = await nft.mintPrice();
            await expect(nft.connect(addr1).mintNFT(addr1.address, 1, { value: mintCost2 })).to.be.revertedWith("Amount exceeds max supply");
        });

        it("Should revert if incorrect amount is sent", async function (){
            const leaf = keccak256(leaves[0]);
            const proof = tree.getHexProof(leaf);
            const mintCost = await nft.presaleMintPrice();
            await expect(nft.connect(addr2).presaleMintNFT(proof, 1, { value: mintCost.sub(1) })).to.be.revertedWith("Incorrect amount of ETH sent");
            await nft.connect(addr1).togglePresale();
            const mintCost2 = await nft.mintPrice();
            await expect(nft.connect(addr1).mintNFT(addr1.address, 1, { value: mintCost2.sub(1) })).to.be.revertedWith("Incorrect amount of ETH sent");
        });

        it("Should revert if owner trys to withdraw 0 erc20 tokens", async function (){
            await expect(nft.connect(addr1).withdrawERC20(DAI.address)).to.be.revertedWith("No tokens to withdraw");
        });

});
