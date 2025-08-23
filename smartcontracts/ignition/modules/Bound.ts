import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("BoundModule", (m: any) => {
  const bound = m.contract("Bound");

  // Get deployer address from the first account in hardhat config
  const deployer = "0xfe3b557e8fb62b89f4916b721be55ceb828dbd73";

  // Mint 5 bounds of type NTNB for the deployer
  for (let i = 1; i <= 5; i++) {
    m.call(
      bound,
      "createBound",
      [
        deployer, // Deployer address
        `https://api.bound.com/token/NTNB-${i}.json`, // Token URI for NTNB type
      ],
      { id: `createBound_${i}` }
    ); // Unique ID for each call
  }

  return { bound };
});
