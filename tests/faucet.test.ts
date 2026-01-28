import { describe, it, expect, beforeEach } from "vitest";
import { Cl } from "@stacks/transactions";

const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;
const wallet1 = accounts.get("wallet_1")!;
const wallet2 = accounts.get("wallet_2")!;

describe("faucet contract", () => {
  describe("claim", () => {
    it("should allow first-time claim", () => {
      const { result } = simnet.callPublicFn("faucet", "claim", [], wallet1);
      expect(result).toBeOk(Cl.bool(true));
    });

    it("should reject claim during cooldown", () => {
      simnet.callPublicFn("faucet", "claim", [], wallet1);
      const { result } = simnet.callPublicFn("faucet", "claim", [], wallet1);
      expect(result).toBeErr(Cl.uint(100));
    });

    it("should allow claim after cooldown expires", () => {
      simnet.callPublicFn("faucet", "claim", [], wallet1);
      simnet.mineEmptyBlocks(145);
      const { result } = simnet.callPublicFn("faucet", "claim", [], wallet1);
      expect(result).toBeOk(Cl.bool(true));
    });
  });

  describe("get-claim-status", () => {
    it("should return can-claim true for new user", () => {
      const { result } = simnet.callReadOnlyFn(
        "faucet",
        "get-claim-status",
        [Cl.principal(wallet2)],
        wallet2
      );
      expect(result).toBeTuple({
        "can-claim": Cl.bool(true),
        "blocks-remaining": Cl.uint(0),
      });
    });

    it("should return blocks remaining after claim", () => {
      simnet.callPublicFn("faucet", "claim", [], wallet1);
      const { result } = simnet.callReadOnlyFn(
        "faucet",
        "get-claim-status",
        [Cl.principal(wallet1)],
        wallet1
      );
      const tuple = result as any;
      expect(tuple.data["can-claim"]).toStrictEqual(Cl.bool(false));
    });
  });

  describe("get-drip-amount", () => {
    it("should return 1 STX", () => {
      const { result } = simnet.callReadOnlyFn(
        "faucet",
        "get-drip-amount",
        [],
        wallet1
      );
      expect(result).toBeUint(1000000);
    });
  });
});
