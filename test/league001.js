/* global assert, contract, it, before, afterEach, after, artifacts, describe */

let League = artifacts.require('./leagues/League001')
  , LeagueRegistry = artifacts.require('./LeagueRegistry');

let { ensureException } = require("./helpers/utils");


contract('League', async accounts => {

  let owner = accounts[0];
  let instance;

  const className = 'soccer';
  const league = 'FIFA';
  const details = '0x00';


  before('setup contract instance', async () => {
    let leagueRegistry = await LeagueRegistry.deployed();

    await leagueRegistry.createClass(className, { from: owner });
    await leagueRegistry.createLeague(className, league, details, { from: owner });

    let result = await leagueRegistry.getClass.call(className);

    instance = await League.at(result[1][0]);
    assert.equal(await instance.getName.call(), league, "cannot set up league");
  });

  describe('Test cases for league information', async () => {

    it('should successfully retrieve the league name', async () => {
      assert.equal(await instance.getName.call(), league, "name was not retrieved");
    });

    it('should successfully retrieve the league details', async () => {
      assert.equal(await instance.getDetails.call(), details, "details was not retrieved");
    });

    it('should successfully retrieve the league class', async () => {
      assert.equal(await instance.getClass.call(), className, "class was not retrieved");
    });

    it('should successfully retrieve the league version', async () => {
      assert.equal(await instance.getVersion.call(), '0.0.1', "version was not retrieved");
    });

  });

  describe('Test cases for adding seasons', async () => {

    it("should successfully create a new season", async () => {
      let result = await instance.getSeasons.call();
      assert.isArray(result, "unexpected return type on getSeasons");
      assert.lengthOf(result, 0, "new league has unexpected seasons");

      await instance.addSeason(2018, { from: accounts[1] }); // any address (non-owner)
      result = await instance.getSeasons.call();
      assert.isArray(result, "unexpected return type on getSeasons");
      assert.lengthOf(result, 1, "season not added / cannot be retrieved");

      await instance.getSeason.call(2018); // throws exception on failure
    });

    it("should throw exception on duplicate season years", async () => {
      try {
        await instance.addSeason(2018, { from: owner });
      } catch (err) {
        ensureException(err);
        return;
      }

      assert.fail('Expected throw not received');
    });

  });

  describe('Test cases for adding participants', async () => {

    describe('Test cases for valid participant creation', async () => {

      it('should successfully create a new participant', async () => {
        await instance.addParticipant('Canada', '0x0123', {from:owner});
        const participant = await instance.getParticipant.call(1);

        assert.equal(participant[0], 1, 'participant id did not start at 1');
        assert.equal(participant[1], 'Canada', 'participant name was not set');
        assert.equal(participant[2], '0x0123', 'participant details was not set');
      });

    });

    describe('Test cases for invalid participant creation', async () => {

      it('should revert if participant already exists', async () => {
        // TODO
      });

      it('should revert if called by non-owner', async () => {
        try {
          await instance.addParticipant('Poland', '0x0123', { from: accounts[1] });  // non-owner
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

  });

  describe('Test cases for scheduling fixtures', async () => {

    before('Create participants and season', async() => {
      await instance.addSeason(2019, { from: owner });
      await instance.addParticipant('Italy', '0x00', { from: owner });
      await instance.addParticipant('England', '0x00', { from: owner });
    });

    describe('Test cases for valid fixture scheduling', async () => {

      it('should successfully schedule a fixture', async () => {
        await instance.scheduleFixture(2019, [2,3], 153737000, { from: owner});

        const fixture = await instance.getFixture.call(1);

        assert.equal(fixture[0], 1, 'fixture ids did not start at 1');
        assert.isArray(fixture[1], 'unexpected return type');
        assert.lengthOf(fixture[1], 2, 'invalid number of participants');
        assert.equal(fixture[1][0], 2, 'fixture participant was not set');
        assert.equal(fixture[1][1], 3, 'fixture participant was not set');

        assert.equal(fixture[2], 153737000, 'fixture start time was not set');

      });

    });

    describe('Test cases for invalid fixture scheduling', async () => {

      it('should revert if season is not supported', async () => {
        try {
          await instance.scheduleFixture(2020, [2,3], 153737000, { from: owner});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if event already exists', async () => {
        // TODO
      });

      it('should revert if participants do not exist', async () => {
        // TODO
      });

    });
  });

  describe('Test cases for setting league details', async () => {

    it('should successfully set league details', async () => {
      await instance.setDetails('0x001234', { from: owner });
      const details = await instance.getDetails.call();

      assert.equal(details, '0x001234', 'details were not updated');
    });

    it('should revert if non-owner attempts to set league details', async () => {
      try {
        await instance.setDetails('0x00', { from: accounts[1] }); // non-owner
      } catch (err) {
        ensureException(err);
        return;
      }

      assert.fail('Expected throw not received');
    });

  });

  describe('Test cases for setting up resolvers', async () => {

    it('should successfully register a resolver', async () => {

    });

  });

  describe('Test cases for ConsensusManager', async () => {

    describe('Test cases for updating consensus contract', async () => {
      // TODO:pre:blocked Manan => Blocked by resolver implementation
    });

    describe('Test cases for pushing consensus', async () => {
      // TODO:pre:blocked Manan => Blocked by resolver implementation
    });

  });

});
