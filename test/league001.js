/* global assert, contract, it, before, afterEach, after, artifacts, describe */

let League = artifacts.require('./leagues/League001')
  , LeagueRegistry = artifacts.require('./LeagueRegistry')
  , ResolverRegistry = artifacts.require('./ResolverRegistry')
  , MockResolver = artifacts.require('./mocks/MockResolver')
  , { ensureException } = require('./helpers/utils');

contract('League', async accounts => {

  let owner = accounts[0];
  let instance;

  const className = 'soccer';
  const league = 'FIFA';

  before('setup contract instance', async () => {
    const leagueRegistry = await LeagueRegistry.deployed();

    await leagueRegistry.createClass(className, 2, { from: owner });
    await leagueRegistry.createLeague(className, league, { from: owner });

    const result = await leagueRegistry.getClass.call(className);

    instance = await League.at(result[1][0]);
    assert.equal(await instance.getName.call(), league, 'cannot set up league');
  });

  describe('Test cases for league information', async () => {

    it('should successfully retrieve the league name', async () => {
      assert.equal(await instance.getName.call(), league, 'name was not retrieved');
    });

    it('should successfully retrieve the league details', async () => {
      assert.equal(await instance.getDetails.call(), '0x', 'details were not retrieved');
    });

    it('should successfully retrieve the league class', async () => {
      assert.equal(await instance.getClass.call(), className, 'class was not retrieved');
    });

    it('should successfully retrieve the league version', async () => {
      assert.equal(await instance.getVersion.call(), '0.0.1', 'version was not retrieved');
    });

  });

  describe('Test cases for adding seasons', async () => {

    it('should successfully create a new season', async () => {
      let result = await instance.getSeasons.call();
      assert.isArray(result, 'unexpected return type on getSeasons');
      assert.lengthOf(result, 0, 'new league has unexpected seasons');

      await instance.addSeason(2018, { from: accounts[1] }); // any address (non-owner)
      result = await instance.getSeasons.call();
      assert.isArray(result, 'unexpected return type on getSeasons');
      assert.lengthOf(result, 1, 'season not added / cannot be retrieved');

      await instance.getSeason.call(2018); // throws exception on failure
    });

    it('should throw exception on duplicate season years', async () => {
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
        await instance.addParticipant('Canada', '0x0123', { from: owner });

        const isParticipant = await instance.isParticipant.call(1);
        assert.isTrue(isParticipant, 'participant does not exist');

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

    let _start = parseInt((Date.now() / 1000) + 3600);

    before('Create participants and season', async() => {
      await instance.addSeason(2019, { from: owner });
      await instance.addParticipant('Italy', '0x00', { from: owner });
      await instance.addParticipant('England', '0x00', { from: owner });
    });

    describe('Test cases for valid fixture scheduling', async () => {

      it('should successfully schedule a fixture', async () => {

        await instance.scheduleFixture(2019, [2,3], _start, { from: owner});

        const isFixtureScheduled = await instance.isFixtureScheduled.call(1);
        assert.isTrue(isFixtureScheduled, 'fixture was not scheduled');

        const fixture = await instance.getFixture.call(1);

        assert.equal(fixture[0], 1, 'fixture ids did not start at 1');
        assert.isArray(fixture[1], 'unexpected return type');
        assert.lengthOf(fixture[1], 2, 'invalid number of participants');
        assert.equal(fixture[1][0], 2, 'fixture participant was not set');
        assert.equal(fixture[1][1], 3, 'fixture participant was not set');

        assert.equal(fixture[2], _start, 'fixture start time was not set');
      });

    });

    describe('Test cases for invalid fixture scheduling', async () => {

      it('should revert if season is not supported', async () => {
        try {
          await instance.scheduleFixture(2020, [2,3], parseInt((Date.now() / 1000) + 3600), { from: owner});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if the number of participants exceeds the maximum amount', async () => {
        try {
          await instance.scheduleFixture(2019, [1,2,3], _start, { from: owner});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if participants do not exist', async () => {
        try {
          await instance.scheduleFixture(2019, [98,99], _start, { from: owner});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if fixture has already started', async () => {
        try {
          await instance.scheduleFixture(2019, [2,3], _start - 7200, { from: owner});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if event already exists', async () => {
        try {
          await instance.scheduleFixture(2019, [2,3], _start, { from: owner});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
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

    let resolver;

    beforeEach('register resolver in resolver registry', async () => {
      resolver = await MockResolver.new('0.0.1');
      const resolverReg = await ResolverRegistry.deployed();
      await resolverReg.addResolver(className, resolver.address);
      await resolverReg.registerResolver(className, resolver.address, {from: owner});
    });

    describe('Test cases for valid resolver registration', async () => {

      it('should successfully register a resolver', async () => {
        await instance.registerResolver(resolver.address, { from: owner });
        const isResolverRegistered = await instance.isResolverRegistered(resolver.address);

        assert.isTrue(isResolverRegistered, 'resolver was not registered');
      });

    });

    describe('Test cases for invalid resolver registration', async () => {

      it('should revert if resolver is already resolved', async () => {
        await instance.registerResolver(resolver.address, { from: owner });
        try {
          await instance.registerResolver(resolver.address, { from: owner });
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if resolver cannot be used', async () => {
        try {
          await instance.registerResolver(accounts[1], { from: owner }); // invalid resolver address
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if resolver does not support current league version', async () => {
        resolver = await MockResolver.new('0.0.2');
        const resolverReg = await ResolverRegistry.deployed();
        await resolverReg.addResolver(className, resolver.address);
        await resolverReg.registerResolver(className, resolver.address, {from: owner});

        try {
          await instance.registerResolver(resolver.address, { from: owner });
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

  });

  describe('Test cases for resolution', async () => {

    let resolver;
    let resolverReg;
    const fixtureId = 1;
    const betPayload = '0x0123';

    before('schedule fixture', async () => {
      await instance.addSeason(2020, {from: owner});
      await instance.scheduleFixture(2020, [1,2], parseInt((Date.now() / 1000) + 7200), {from: owner});
    });

    beforeEach('register resolver in resolver registry', async () => {
      resolver = await MockResolver.new('0.0.1');
      resolverReg = await ResolverRegistry.deployed();
      await resolverReg.addResolver(className, resolver.address);
      await resolverReg.registerResolver(className, resolver.address, {from: owner});
      await instance.registerResolver(resolver.address, {from: owner});
    });

    describe('Test cases for valid resolution pushed', async () => {

      it('should successfully push a resolution', async () => {
        await instance.pushResolution(fixtureId, resolver.address, betPayload, {from: owner}); // owner is also consensus manager

        let result = await instance.getResolution.call(fixtureId, resolver.address);
        assert.equal(result, betPayload, 'payload was incorrectly set');

        result = await instance.isFixtureResolved.call(fixtureId, resolver.address);
        assert.equal(result.toNumber(), 1, 'fixture was not resolved');

        const resolvers = await resolverReg.getResolvers.call(className);
        result = await instance.isFixtureResolved.call(fixtureId, resolvers[0]);
        assert.equal(result.toNumber(), 2, 'fixture was not resolved');
      });

    });

    describe('Test cases for invalid resolution pushed', async () => {

      it('should revert if fixture was not scheduled for the league', async () => {
        try {
          await instance.pushResolution(9999, resolver.address, betPayload, {from: owner}); // owner is also consensus manager
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if league does not support the given resolver', async () => {
        try {
          await instance.pushResolution(fixtureId, accounts[1], betPayload, {from: owner}); // accounts[1] is an invalid resolver
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if not called from non-consensus manager', async () => {
        try {
          await instance.pushResolution(fixtureId, accounts[1], betPayload, {from: accounts[1]});  // accounts[1] is not consensus manager
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

    describe('Test cases for retrieving resolution', async () => {

      it('should revert if resolver is not resolved for fixture', async () => {
        try {
          await instance.getResolution.call(1, resolver.address);
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

  });

  describe('Test cases for retrieving seasons', async () => {

    it('should revert when retrieving a season that is not supported', async () => {
      try {
        await instance.getSeason.call(9999);
      } catch (err) {
        ensureException(err);
        return;
      }

      assert.fail('Expected throw not received');
    });

  });

  describe('Test cases for retrieving fixtures', async () => {

    it('should revert when a fixture is not scheduled', async () => {
      try {
        await instance.getFixture.call(9999);
      } catch (err) {
        ensureException(err);
        return;
      }

      assert.fail('Expected throw not received');
    });

  });

  describe('Test cases for retrieving participants', async () => {

    it('should revert when a participant does not exist', async () => {
      try {
        await instance.getParticipant.call(9999);
      } catch (err) {
        ensureException(err);
        return;
      }

      assert.fail('Expected throw not received');
    });

  });

  describe('Test cases for fixture participant validation', async () => {

    const participants = [1,2];
    let fixtureId;

    before('create fixture', async () => {
      const result = await instance.scheduleFixture(2019, participants, parseInt((Date.now() / 1000) + 10800), { from: owner});
      fixtureId = result.logs[0].args._id;
    });

    it('should return `true` if participant is scheduled for the fixture', async () => {
      let result = await instance.isParticipantScheduled.call(participants[0], fixtureId);
      assert.isTrue(result);

      result = await instance.isParticipantScheduled.call(participants[1], fixtureId);
      assert.isTrue(result);
    });

    it('should return `false` if participant is not scheduled for the fixture', async () => {
      let result = await instance.isParticipantScheduled.call(3, fixtureId);
      assert.isFalse(result);
    });

    it('should revert if participant is not in league', async () => {
      try {
        await instance.isParticipantScheduled.call(9999, fixtureId);
      } catch (err) {
        ensureException(err);
        return;
      }

      assert.fail('Expected throw not received');
    });

    it('should revert if fixture is not scheduled', async () => {
      try {
        await instance.isParticipantScheduled.call(1, 9999);
      } catch (err) {
        ensureException(err);
        return;
      }

      assert.fail('Expected throw not received');
    });

  });

});
