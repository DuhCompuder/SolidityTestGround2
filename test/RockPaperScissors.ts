import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract, Signer } from "ethers";

describe("Game of Rock Paper Scissors", function () {
  let game: Contract;
  let userPlayerOne: Signer;
  let userPlayerTwo: Signer;

  beforeEach(async () => {
    const Game = await ethers.getContractFactory("Game");
    game = await Game.deploy();
    [userPlayerOne, userPlayerTwo] = await ethers.getSigners();
  });

  describe("Playing with Other User", function () {
    it("Start a game with a player", async function () {
      const gameNumber: Number = await game.getGameCount();
      expect(await game.connect(userPlayerOne).playWithAPlayer(0))
        .to.emit(game, "PlayerSelections")
        .withArgs(gameNumber, "PlayerA", userPlayerOne.getAddress, 0, "Rock");
    });
    it("Successfully plays against another player", async function () {
      const gameNumber: Number = await game.getGameCount();
      await game.connect(userPlayerOne).playWithAPlayer(0);
      expect(await game.connect(userPlayerTwo).playWithAPlayer(1))
        .to.emit(game, "PlayerSelections")
        .withArgs(gameNumber, "PlayerB", userPlayerOne.getAddress, 0, "Paper");
    });
    it("Reverts if same play tries to play themselves.", async function () {
      await game.connect(userPlayerOne).playWithAPlayer(0);
      await expect(
        game.connect(userPlayerOne).playWithAPlayer(1)
      ).to.be.revertedWith(
        "PlayerB cannot be the same player as playerA, please select option with a different account."
      );
    });
  });
  describe("Playing with Computer", function () {
    it("Start a game with a computer", async function () {
      const tx = await game.connect(userPlayerOne).playWithComputer(1);
      console.log("tx: ", tx);
      //   const receipt = await tx.wait();
      //   for (const event of receipt.events) {
      //     console.log(`Event ${event.event} with args ${event.args}`);
      //   }
      //   const gameNumber = await game.getGameCount();
      //   expect(await game.connect(userPlayerOne).playWithComputer(1))
      //     .to.emit(game, "PlayerSelections")
      //     .withArgs(gameNumber, "PlayerA", userPlayerOne.getAddress, 0, "Rock");
    });
  });
  describe("Determine Game Reuslts", function () {
    it("Start a game with a computer", async function () {
      //   const tx = await game.connect(userPlayerOne).playWithComputer(1);
      //   const receipt = await tx.wait();
      //   for (const event of receipt.events) {
      //     console.log(`Event ${event.event} with args ${event.args}`);
      //   }
      const gameNumber = await game.getGameCount();
      expect(await game.connect(userPlayerOne).playWithComputer(1))
        .to.emit(game, "PlayerSelections")
        .withArgs(gameNumber, "PlayerA", userPlayerOne.getAddress, 0, "Rock");
    });
  });
});
