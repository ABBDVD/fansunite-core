## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| contracts/extensions/ILeagueExtension.sol | aec3dd3178e07fb54f631448a7604cfa8f3fb54f |
| contracts/interfaces/IBetManager.sol | 540cc9f62579f089cbd9817d580a412ae69451de |
| contracts/interfaces/ILeague.sol | f865eb07ce78968c0e6587601d781cc594550287 |
| contracts/interfaces/ILeagueFactory.sol | 2dd6d3b3e399ef8181fc03097cda40b686f398fa |
| contracts/interfaces/ILeagueRegistry.sol | 2497934465692ef53a556c4f8ec844df3e24bcf4 |
| contracts/interfaces/IRegistry.sol | 30d5540f20c99f278ab76f77b16c962f0d697658 |
| contracts/interfaces/IResolver.sol | 25eed731ad230e90ee1edc79269e63c4b8dbea6a |
| contracts/interfaces/IResolverRegistry.sol | 3aae8518abc4b461bd43e0b40b060c521232770d |
| contracts/interfaces/IVault.sol | c009b5d0a1b36cd8685567980dcc9ed75e655984 |
| contracts/introspection/ERC165.sol | 4b111a49b787497385348b5580cac7ba08828543 |
| contracts/leagues/BaseLeague.sol | 908866a16809d85907ac2580b61a68200ecb224f |
| contracts/leagues/ILeague001.sol | f4329be5cf02bc20ed665d1e35ab6648c527078e |
| contracts/leagues/League001.sol | eaa05996c7d5998c3d3700734a6f86b24b5374a7 |
| contracts/leagues/LeagueFactory001.sol | 102ec1fb2ccba5543ba311f3fcf028ee6cd8be36 |
| contracts/leagues/LeagueLib001.sol | f84b634dac32b1a79972015fbb07c36653540849 |
| contracts/libraries/BetLib.sol | ab7e40b567115367459696a2e30965a4e5af09c1 |
| contracts/libraries/SignatureLib.sol | 807ccb76ffd2a12506f48e691b1a13f482e9c9d9 |
| contracts/resolvers/BaseResolver.sol | 689fc2ff14d9ec0f29d71d6227d2503fe3859d32 |
| contracts/resolvers/RMoneyLine2.sol | 5569f305e601889dc70e68d44283f2fb621d6362 |
| contracts/resolvers/RSpreads2.sol | fd4b7a0be3c8a4687fb930dd32d371a0b4e6d888 |
| contracts/resolvers/RTotals2.sol | 105cdace81254d66193cb12af67aadfc344a189b |
| contracts/tokens/FanToken.sol | 2d50a7b5030df88b48c599df387a679699f07cef |
| contracts/utils/ChainSpecifiable.sol | 282bb75e88a17401c12a3e2ac99e7b59ad398241 |
| contracts/utils/RegistryAccessible.sol | 1dd156db62f0ca75588f174e3da6b87df76e8162 |
| contracts/vault/Vault.sol | f8b24fb66419113693924a1dcd1afd57f7a694c6 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ILeagueExtension** | Implementation |  |||
| └ | getFixtures | External ❗️ |   | |
||||||
| **IBetManager** | Implementation |  |||
| └ | submitBet | External ❗️ | 🛑  | |
| └ | claimBet | External ❗️ | 🛑  | |
| └ | getResult | External ❗️ |   | |
| └ | getBetsBySubject | External ❗️ |   | |
||||||
| **ILeague** | Implementation |  |||
| └ | pushResolution | External ❗️ | 🛑  | |
| └ | setDetails | External ❗️ | 🛑  | |
| └ | getResolution | External ❗️ |   | |
| └ | getFixtureStart | External ❗️ |   | |
| └ | isFixtureScheduled | External ❗️ |   | |
| └ | isFixtureResolved | External ❗️ |   | |
| └ | isParticipant | External ❗️ |   | |
| └ | isParticipantScheduled | External ❗️ |   | |
| └ | getName | External ❗️ |   | |
| └ | getClass | External ❗️ |   | |
| └ | getDetails | External ❗️ |   | |
| └ | getVersion | External ❗️ |   | |
||||||
| **ILeagueFactory** | Implementation |  |||
| └ | deployLeague | External ❗️ | 🛑  | |
||||||
| **ILeagueRegistry** | Implementation |  |||
| └ | createClass | External ❗️ | 🛑  | |
| └ | createLeague | External ❗️ | 🛑  | |
| └ | addFactory | External ❗️ | 🛑  | |
| └ | setFactoryVersion | External ❗️ | 🛑  | |
| └ | getClass | External ❗️ |   | |
| └ | getLeague | External ❗️ |   | |
| └ | getFactoryVersion | External ❗️ |   | |
| └ | getFactory | External ❗️ |   | |
| └ | isLeagueRegistered | External ❗️ |   | |
| └ | isClassSupported | External ❗️ |   | |
||||||
| **IRegistry** | Implementation |  |||
| └ | getAddress | Public ❗️ |   | |
| └ | changeAddress | Public ❗️ | 🛑  | |
||||||
| **IResolver** | Implementation |  |||
| └ | doesSupportLeague | External ❗️ |   | |
| └ | getInitSignature | External ❗️ |   | |
| └ | getInitSelector | External ❗️ |   | |
| └ | getValidatorSignature | External ❗️ |   | |
| └ | getValidatorSelector | External ❗️ |   | |
| └ | getDescription | External ❗️ |   | |
| └ | getType | External ❗️ |   | |
| └ | getDetails | External ❗️ |   | |
||||||
| **IResolverRegistry** | Implementation |  |||
| └ | addResolver | External ❗️ | 🛑  | |
| └ | registerResolver | External ❗️ | 🛑  | |
| └ | rejectResolver | External ❗️ | 🛑  | |
| └ | nukeResolver | External ❗️ | 🛑  | |
| └ | useResolver | External ❗️ | 🛑  | |
| └ | getResolvers | External ❗️ |   | |
| └ | isResolverRegistered | External ❗️ |   | |
| └ | isResolverUsed | External ❗️ |   | |
||||||
| **IVault** | Implementation |  |||
| └ | deposit | External ❗️ |  💵 | |
| └ | withdraw | External ❗️ | 🛑  | |
| └ | transfer | External ❗️ | 🛑  | |
| └ | transferFrom | External ❗️ | 🛑  | |
| └ | approve | External ❗️ | 🛑  | |
| └ | addSpender | External ❗️ | 🛑  | |
| └ | balanceOf | External ❗️ |   | |
| └ | isApproved | External ❗️ |   | |
| └ | isSpender | External ❗️ |   | |
||||||
| **ERC165** | Interface |  |||
| └ | supportsInterface | External ❗️ |   | |
||||||
| **BaseLeague** | Implementation | Ownable, RegistryAccessible |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | RegistryAccessible |
| └ | setDetails | External ❗️ | 🛑  | onlyOwner |
| └ | getName | External ❗️ |   | |
| └ | getClass | External ❗️ |   | |
| └ | getDetails | External ❗️ |   | |
||||||
| **ILeague001** | Implementation | ILeague |||
| └ | addSeason | External ❗️ | 🛑  | |
| └ | scheduleFixture | External ❗️ | 🛑  | |
| └ | addParticipant | External ❗️ | 🛑  | |
| └ | getSeasons | External ❗️ |   | |
| └ | getSeason | External ❗️ |   | |
| └ | getFixture | External ❗️ |   | |
| └ | getParticipant | External ❗️ |   | |
| └ | getParticipantCount | External ❗️ |   | |
||||||
| **League001** | Implementation | ILeague001, BaseLeague |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | BaseLeague |
| └ | pushResolution | External ❗️ | 🛑  | onlyConsensus |
| └ | addSeason | External ❗️ | 🛑  | |
| └ | scheduleFixture | External ❗️ | 🛑  | |
| └ | addParticipant | External ❗️ | 🛑  | onlyOwner |
| └ | getResolution | External ❗️ |   | |
| └ | getSeasons | External ❗️ |   | |
| └ | getSeason | External ❗️ |   | |
| └ | getFixtureStart | External ❗️ |   | |
| └ | getFixture | External ❗️ |   | |
| └ | getParticipant | External ❗️ |   | |
| └ | getParticipantCount | External ❗️ |   | |
| └ | isFixtureScheduled | External ❗️ |   | |
| └ | isFixtureResolved | External ❗️ |   | |
| └ | isParticipant | External ❗️ |   | |
| └ | isParticipantScheduled | External ❗️ |   | |
| └ | _isFixtureScheduled | Internal 🔒 |   | |
| └ | _isFixtureResolved | Internal 🔒 |   | |
| └ | _isParticipant | Internal 🔒 |   | |
| └ | _areParticipants | Internal 🔒 |   | |
| └ | _isSeasonSupported | Internal 🔒 |   | |
| └ | getVersion | External ❗️ |   | |
||||||
| **LeagueFactory001** | Implementation | ILeagueFactory |||
| └ | deployLeague | External ❗️ | 🛑  | |
||||||
| **LeagueLib001** | Library |  |||
| └ | hashRawFixture | Internal 🔒 |   | |
| └ | hashRawParticipant | Internal 🔒 |   | |
||||||
| **BetLib** | Library |  |||
| └ | generate | Internal 🔒 |   | |
| └ | hash | Internal 🔒 |   | |
| └ | backerReturn | Internal 🔒 |   | |
||||||
| **SignatureLib** | Library |  |||
| └ | isValidSignature | Internal 🔒 |   | |
| └ | recover | Internal 🔒 |   | |
||||||
| **BaseResolver** | Implementation | Ownable |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | |
| └ | supportVersion | External ❗️ | 🛑  | onlyOwner |
| └ | doesSupportLeague | External ❗️ |   | |
||||||
| **RMoneyLine2** | Implementation | IResolver, BaseResolver |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | BaseResolver |
| └ | resolve | External ❗️ |   | |
| └ | validate | External ❗️ |   | |
| └ | getInitSignature | External ❗️ |   | |
| └ | getInitSelector | External ❗️ |   | |
| └ | getValidatorSignature | External ❗️ |   | |
| └ | getValidatorSelector | External ❗️ |   | |
| └ | getDescription | External ❗️ |   | |
| └ | getType | External ❗️ |   | |
| └ | getDetails | External ❗️ |   | |
||||||
| **RSpreads2** | Implementation | IResolver, BaseResolver |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | BaseResolver |
| └ | resolve | External ❗️ |   | |
| └ | validate | External ❗️ |   | |
| └ | getInitSignature | External ❗️ |   | |
| └ | getInitSelector | External ❗️ |   | |
| └ | getValidatorSignature | External ❗️ |   | |
| └ | getValidatorSelector | External ❗️ |   | |
| └ | getDescription | External ❗️ |   | |
| └ | getType | External ❗️ |   | |
| └ | getDetails | External ❗️ |   | |
||||||
| **RTotals2** | Implementation | IResolver, BaseResolver |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | BaseResolver |
| └ | resolve | External ❗️ |   | |
| └ | validate | External ❗️ |   | |
| └ | getInitSignature | External ❗️ |   | |
| └ | getInitSelector | External ❗️ |   | |
| └ | getValidatorSignature | External ❗️ |   | |
| └ | getValidatorSelector | External ❗️ |   | |
| └ | getDescription | External ❗️ |   | |
| └ | getType | External ❗️ |   | |
| └ | getDetails | External ❗️ |   | |
||||||
| **FanToken** | Implementation | ERC20Detailed, ERC20Capped |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | ERC20Detailed ERC20Capped |
||||||
| **ChainSpecifiable** | Implementation | Ownable |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | |
| └ | setChainId | Public ❗️ | 🛑  | onlyOwner |
| └ | getChainId | Public ❗️ |   | |
||||||
| **RegistryAccessible** | Implementation | Ownable |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | |
| └ | getRegistryContract | Public ❗️ |   | |
||||||
| **Vault** | Implementation | Ownable, IVault, RegistryAccessible |||
| └ | \<Constructor\> | Public ❗️ | 🛑  | RegistryAccessible |
| └ | deposit | External ❗️ |  💵 | |
| └ | withdraw | External ❗️ | 🛑  | |
| └ | transfer | External ❗️ | 🛑  | |
| └ | transferFrom | External ❗️ | 🛑  | onlyApproved |
| └ | approve | External ❗️ | 🛑  | |
| └ | addSpender | External ❗️ | 🛑  | onlyOwner |
| └ | balanceOf | External ❗️ |   | |
| └ | isApproved | External ❗️ |   | |
| └ | isSpender | External ❗️ |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
