let Web3 = require('web3')
  , web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));

class BetFactory {

  constructor(defaultBetParams) {
    this._defaultBetParams = defaultBetParams;
    this._nonce = 1;
  }

  async newSignedBet(betParams) {
    this._nonce++;
    const b = {
      ...this._defaultBetParams,
      ...betParams
    };

    const betHash = this.hashBet(b);

    return {
      addresses: [
        b.backer,
        b.layer,
        b.token,
        b.feeRecipient,
        b.league,
        b.resolver
      ],
      values: [
        b.backerStake,
        b.backerFee,
        b.layerFee,
        b.expiration,
        b.fixture,
        b.odds
      ],
      payload: b.payload,
      nonce: this._nonce,
      signature: await this.signBet(b, betHash),
      betHash
    };
  }

  hashBet(bet) {

    const schema = [
      "Bet(",
      "address backer,",
      "address layer,",
      "address token,",
      "address feeRecipient,",
      "address league,",
      "address resolver,",
      "uint256 backerStake,",
      "uint256 backerFee,",
      "uint256 layerFee,",
      "uint256 expiration,",
      "uint256 fixture,",
      "uint256 odds,",
      "bytes payload",
      ")"
    ];

    const newBet = {
      backer: bet.backer,
      layer: bet.layer,
      token: bet.token,
      feeRecipient: bet.feeRecipient,
      league: bet.league,
      resolver: bet.resolver,
      backerStake: bet.backerStake,
      backerFee: bet.backerFee,
      layerFee: bet.layerFee,
      expiration: bet.expiration,
      fixture: bet.fixture,
      odds: bet.odds
    };

    let payloadHash = Web3.utils.soliditySha3.apply(null, [ bet.payload ]);
    let schemaHash = Web3.utils.soliditySha3.apply(null, schema);
    let values = [ schemaHash, ...Object.values(newBet), payloadHash ];
    let hash = Web3.utils.soliditySha3.apply(null, values);
    return Web3.utils.soliditySha3.apply(null, [ this._nonce, hash ]);
  }

  async signBet(bet, betHash) {
    let sig = (await web3.eth.sign(betHash, bet.backer)).slice(2);

    let r = Buffer.from(sig.substring(0, 64), 'hex');
    let s = Buffer.from(sig.substring(64, 128), 'hex');
    let v = Buffer.from((parseInt(sig.substring(128, 130), 16) + 27).toString(16), 'hex');
    let mode = Buffer.from('01', 'hex');

    return '0x' + Buffer.concat([mode, v, r, s]).toString('hex');
  }
}

module.exports = {
  BetFactory
};
