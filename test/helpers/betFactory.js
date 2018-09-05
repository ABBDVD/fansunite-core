let Web3 = require('web3')
  , web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));

class BetFactory {

  constructor(defaultBetParams) {
    this._defaultBetParams = defaultBetParams;
    this._nonce = 1;
  }

  async generate(betParams) {
    this._nonce++;

    const _bet = {
      ...this._defaultBetParams,
      ...betParams
    };

    let hash = this.hashBet(_bet);
    let signature = BetFactory.signBet(_bet, hash);

    return {
      subjects: [
        _bet.backer,
        _bet.layer,
        _bet.token,
        _bet.league,
        _bet.resolver
      ],
      params: [
        _bet.backerStake,
        _bet.fixture,
        _bet.odds,
        _bet.expiration
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
      "address league,",
      "address resolver,",
      "uint256 backerStake,",
      "uint256 fixture,",
      "uint256 odds,",
      "uint256 expiration,",
      "bytes payload",
      ")"
    ];

    let subjects = [
      bet.backer,
      bet.layer,
      bet.token,
      bet.league,
      bet.resolver
    ];

    let params = [
      bet.backerStake,
      bet.fixture,
      bet.odds,
      bet.expiration,
    ];

    let payloadHash = Web3.utils.soliditySha3.apply(null, [ bet.payload ]);
    let schemaHash = Web3.utils.soliditySha3.apply(null, schema);
    let eip712Hash = Web3.utils.soliditySha3.apply(null, [ schemaHash, ...subjects, ...params, payloadHash ]);
    return Web3.utils.soliditySha3.apply(null, [ this._nonce, eip712Hash ]);
  }

  static async signBet(bet, hash) {
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
