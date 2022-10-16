const { expect } = require('chai');

describe('DAO Contract', () => {
	let DAO, roulette, TOKEN, owner, addr1, addr2;

	beforeEach(async () => {
		[owner, addr1, addr2, _] = await ethers.getSigners()
		let TOKEN_CONTRACT = await ethers.getContractFactory("MyToken");
		TOKEN = await TOKEN_CONTRACT.deploy()
		console.log("token.address", TOKEN.address)
		let DAO_CONTRACT = await ethers.getContractFactory("TheOpenLottoDAO");
		DAO = await DAO_CONTRACT.deploy(TOKEN.address,TOKEN.address)
	
		let lastNumbers = []
		let userNumbers = []
	});
	describe('Deployment', () => {
		it('Should get the right owner', async () => {
			console.log("owner.address", owner.address)
			console.log("token.address", TOKEN.address)
			console.log("dao.address", DAO.address)
			expect(await DAO.owner()).to.equal(owner.address)
		})
		it('Should have minted a token', async () => {
			let totalSupply = await TOKEN.totalSupply();
			console.log("totalSupply",ethers.utils.formatEther(totalSupply),totalSupply.toString())
			expect(totalSupply).to.equal(ethers.utils.parseEther("100000"))
		})
		it('Should have signed up to DAO', async () => {
			await TOKEN.connect(owner).approve(DAO.address, ethers.utils.parseEther("999"));
		})
		it('Should have all balance', async () => {
			let balanceOfOwner = await TOKEN.balanceOf(owner.address);
			expect(balanceOfOwner).to.equal(ethers.utils.parseEther("100000"))
		})
		it('Should have one proposal', async () => {
			await TOKEN.connect(owner).approve(DAO.address, ethers.utils.parseEther("999"));
			let creation = await DAO.connect(owner).createProposal(1000, 5); await creation.wait()
			console.log("proposal created!")
			let numProposals = await DAO.numProposals(); console.log("numProposals", numProposals.toString())

			expect(numProposals).to.equal(1)
		})
	})
})