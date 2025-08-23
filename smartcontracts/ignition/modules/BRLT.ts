import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("BRLTModule", (m: any) => {
  const brlt = m.contract("BRLT");

  return { brlt: brlt };
});
