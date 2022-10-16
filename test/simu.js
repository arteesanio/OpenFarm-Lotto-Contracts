const { expect } = require('chai');

describe('Simulation Contract', () => {
	let SIMULATION, owner, addr1, addr2;

	beforeEach(async () => {
		[owner, addr1, addr2, _] = await ethers.getSigners()
		let SIMULATION_CONTRACT = await ethers.getContractFactory("TheOpenSimulation");
		SIMULATION = await SIMULATION_CONTRACT.deploy()
		console.log("simulation address", SIMULATION.address)
	});
	describe('Deployment', () => {
		it('Should have thoughts', async () => {
			console.log("SIMULATION address", SIMULATION.address)
			let supernaturalThoughtItem = await SIMULATION.thoughts(0,0)
			console.log("supernaturalThoughtItem", supernaturalThoughtItem)
			expect(supernaturalThoughtItem.id).to.equal(0)
		})
		it('Should create player', async () => {
			let aTestPlayerResult = await SIMULATION._createTestPlayer(addr2.address)
		})
		it('Should create player with and without ref', async () => {
			let aTestPlayerResult = await SIMULATION._createTestPlayer(addr2.address)

			let aPlayerResult = await SIMULATION.connect(addr1).createPlayer(addr2.address,"myname")
			let anOwner = await SIMULATION.connect(owner).createPlayer(SIMULATION.address,"owner")

			let ownerPlayerMemory = await SIMULATION.connect(owner).getMyMemory(0)
			console.log("\n\n",ownerPlayerMemory.thoughtCat)
			console.log("\n\n",ownerPlayerMemory)
			
			let playerLegacy = await SIMULATION.connect(addr1).getMyLegacy()
			console.log("\n\n",playerLegacy)
		})
	})
})