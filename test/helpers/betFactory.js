let Web3 = require('web3')
  , web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));

class BetFactory {

  constructor(defaultBetParams) {
    this._defaultBetParams = defaultBetParams;
    this._nonce = 1;
  }

  async newSignedBet(betParams) {
    this._nonce++;

    const _bet = {
      ...this._defaultBetParams,
      ...betParams
    };

    let hash = this.hashBet(_bet);
    let signature = this.signBet(_bet, hash);

    return {
      addresses: [
        _bet.backer,
        _bet.layer,
        _bet.token,
        _bet.feeRecipient,
        _bet.league,
        _bet.resolver
      ],
      values: [
        _bet.backerStake,
        _bet.backerFee,
        _bet.layerFee,
        _bet.expiration,
        _bet.fixture,
        _bet.odds
      ],
      payload: _bet.payload,
      bet: _bet,
      nonce: this._nonce,
      hash,
      signature
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

    let _addresses = [
      bet.backer,
      bet.layer,
      bet.token,
      bet.feeRecipient,
      bet.league,
      bet.resolver
    ];

    let _values = [
      bet.backerStake,
      bet.backerFee,
      bet.layerFee,
      bet.expiration,
      bet.fixture,
      bet.odds
    ];

    let payloadHash = Web3.utils.soliditySha3.apply(null, [ bet.payload ]);
    let schemaHash = Web3.utils.soliditySha3.apply(null, schema);
    let eip712Hash = Web3.utils.soliditySha3.apply(null, [ schemaHash, ..._addresses, ..._values, payloadHash ]);
    return Web3.utils.soliditySha3.apply(null, [ this._nonce, eip712Hash ]);
  }

  async signBet(bet, hash) {
    let sig = (await web3.eth.sign(hash, bet.backer)).slice(2);

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
