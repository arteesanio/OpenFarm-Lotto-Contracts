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
	})
})