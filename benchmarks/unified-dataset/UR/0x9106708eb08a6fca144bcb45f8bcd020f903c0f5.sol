 

pragma solidity ^0.4.19;

 

 
contract ERC721 {
    function implementsERC721() public pure returns (bool);
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) public view returns (address owner);
    function approve(address _to, uint256 _tokenId) public;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function transfer(address _to, uint256 _tokenId) public;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

     
     
     
     
     
}

 

contract FighterCoreInterface is ERC721 {
    function getFighter(uint256 _id)
        public
        view
        returns (
        uint256 prizeCooldownEndTime,
        uint256 battleCooldownEndTime,
        uint256 prizeCooldownIndex,
        uint256 battlesFought,
        uint256 battlesWon,
        uint256 generation,
        uint256 genes,
        uint256 dexterity,
        uint256 strength,
        uint256 vitality,
        uint256 luck,
        uint256 experience
    );
    
    function createPrizeFighter(
        uint16 _generation,
        uint256 _genes,
        uint8 _dexterity,
        uint8 _strength,
        uint8 _vitality,
        uint8 _luck,
        address _owner
    ) public;
    
    function updateFighter(
        uint256 _fighterId,
        uint8 _dexterity,
        uint8 _strength,
        uint8 _vitality,
        uint8 _luck,
        uint32 _experience,
        uint64 _prizeCooldownEndTime,
        uint16 _prizeCooldownIndex,
        uint64 _battleCooldownEndTime,
        uint16 _battlesFought,
        uint16 _battlesWon
    ) public;

    function updateFighterBattleStats(
        uint256 _fighterId,
        uint64 _prizeCooldownEndTime,
        uint16 _prizeCooldownIndex,
        uint64 _battleCooldownEndTime,
        uint16 _battlesFought,
        uint16 _battlesWon
    ) public;

    function updateDexterity(uint256 _fighterId, uint8 _dexterity) public;
    function updateStrength(uint256 _fighterId, uint8 _strength) public;
    function updateVitality(uint256 _fighterId, uint8 _vitality) public;
    function updateLuck(uint256 _fighterId, uint8 _luck) public;
    function updateExperience(uint256 _fighterId, uint32 _experience) public;
}

 

contract BattleDeciderInterface {
    function isBattleDecider() public pure returns (bool);
    function determineWinner(uint256[7][] teamAttacker, uint256[7][] teamDefender) public returns (
        bool attackerWon,
        uint256 xpForAttacker,
        uint256 xpForDefender
    );
}

 

 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  function Ownable() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 

 
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

   
  modifier whenPaused() {
    require(paused);
    _;
  }

   
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

 

 
contract GeneScienceInterface {
     
    function isGeneScience() public pure returns (bool);

     
     
     
     
    function mixGenes(uint256 genes1, uint256 genes2) public returns (uint256);
}

 

contract BattleBase is Ownable, Pausable {
    event TeamCreated(uint256 indexed teamId, uint256[] fighterIds);
    event TeamDeleted(uint256 indexed teamId, uint256[] fighterIds);
    event BattleResult(address indexed winnerAddress, address indexed loserAddress, uint256[] attackerFighterIds, uint256[] defenderFighterIds, bool attackerWon, uint16 prizeFighterGeneration, uint256 prizeFighterGenes, uint32 attackerXpGained, uint32 defenderXpGained);
    
    struct Team {
        address owner;
        uint256[] fighterIds;
    }

    struct RaceBaseStats {
        uint8 strength;
        uint8 dexterity;
        uint8 vitality;
    }
    
    Team[] public teams;
     
    RaceBaseStats[] public raceBaseStats;
    
    uint256 internal randomCounter = 0;
    
    FighterCoreInterface public fighterCore;
    GeneScienceInterface public geneScience;
    BattleDeciderInterface public battleDecider;
    
    mapping (uint256 => uint256) public fighterIndexToTeam;
    mapping (uint256 => bool) public teamIndexToExist;
     
     
    
     
    uint256[] public deletedTeamIds;
    
    uint256 public maxPerTeam = 5;

    uint8[] public genBaseStats = [
        16,  
        12,  
        10,  
        8,  
        7,  
        6,  
        5,  
        4,  
        3,  
        2,  
        1  
    ];
    
     
     
     
     
     
     
     
    
    modifier onlyTeamOwner(uint256 _teamId) {
        require(teams[_teamId].owner == msg.sender);
        _;
    }

    modifier onlyExistingTeam(uint256 _teamId) {
        require(teamIndexToExist[_teamId] == true);
        _;
    }

    function teamExists(uint256 _teamId) public view returns (bool) {
        return teamIndexToExist[_teamId] == true;
    }

     
    function randMod(uint256 _randCounter, uint _modulus) internal view returns (uint256) { 
        return uint(keccak256(now, msg.sender, _randCounter)) % _modulus;
    }

    function getDeletedTeams() public view returns (uint256[]) {
         
        return deletedTeamIds;
    }

    function getRaceBaseStats(uint256 _id) public view returns (
        uint256 strength,
        uint256 dexterity,
        uint256 vitality
    ) {
        RaceBaseStats storage race = raceBaseStats[_id];
        
        strength = race.strength;
        dexterity = race.dexterity;
        vitality = race.vitality;
    }
}

 

contract BattleAdmin is BattleBase {
    event ContractUpgrade(address newContract);

    address public newContractAddress;
    
     
    uint256 public secondsPerBlock = 15;

    uint32[7] public prizeCooldowns = [
        uint32(1 minutes),
        uint32(30 minutes),
        uint32(2 hours),
        uint32(6 hours),
        uint32(12 hours),
        uint32(1 days),
        uint32(3 days)
    ];

    function setFighterCoreAddress(address _address) public onlyOwner {
        _setFighterCoreAddress(_address);
    }

    function _setFighterCoreAddress(address _address) internal {
        FighterCoreInterface candidateContract = FighterCoreInterface(_address);

        require(candidateContract.implementsERC721());

        fighterCore = candidateContract;
    }
    
    function setGeneScienceAddress(address _address) public onlyOwner {
        _setGeneScienceAddress(_address);
    }

    function _setGeneScienceAddress(address _address) internal {
        GeneScienceInterface candidateContract = GeneScienceInterface(_address);

        require(candidateContract.isGeneScience());

        geneScience = candidateContract;
    }

    function setBattleDeciderAddress(address _address) public onlyOwner {
        _setBattleDeciderAddress(_address);
    }

    function _setBattleDeciderAddress(address _address) internal {
        BattleDeciderInterface deciderCandidateContract = BattleDeciderInterface(_address);

        require(deciderCandidateContract.isBattleDecider());

        battleDecider = deciderCandidateContract;
    }

    function addRace(uint8 _strength, uint8 _dexterity, uint8 _vitality) public onlyOwner {
        raceBaseStats.push(RaceBaseStats({
            strength: _strength,
            dexterity: _dexterity,
            vitality: _vitality
        }));
    }

     
    function removeLastRace() public onlyOwner {
         
        require(raceBaseStats.length > 4);
        
        delete raceBaseStats[raceBaseStats.length - 1];
    }

     
     
     
     
     
    function setNewAddress(address _v2Address) public onlyOwner whenPaused {
        newContractAddress = _v2Address;
        
        ContractUpgrade(_v2Address);
    }

     
    function setSecondsPerBlock(uint256 _secs) external onlyOwner {
        require(_secs < prizeCooldowns[0]);
        secondsPerBlock = _secs;
    }
}

 

contract BattlePrize is BattleAdmin {
     
    uint32[50] public stats = [
        0,
        100,
        300,
        600,
        1000,
        1500,
        2100,
        2800,
        3600,
        4500,
        5500,
        6600,
        7800,
        9100,
        10500,
        12000,
        13600,
        15300,
        17100,
        19000,
        21000,
        23100,
        25300,
        27600,
        30000,
        32500,
        35100,
        37800,
        40600,
        43500,
        46500,
        49600,
        52800,
        56100,
        59500,
        63000,
        66600,
        70300,
        74100,
        78000,
        82000,
        86100,
        90300,
        94600,
        99000,
        103500,
        108100,
        112800,
        117600,
        122500
    ];

    uint8[11] public extraStatsForGen = [
        16,  
        12,  
        10,  
        8,  
        7,  
        6,  
        5,  
        4,  
        3,  
        2,  
        1  
    ];

     
    uint8 public battlesTillBattleCooldown = 5;
     
    uint32 public experienceDelay = uint32(6 hours);

     
     
     
     
     
     
    function genToLuck(uint256 _gen, uint256 _rand) public pure returns (uint8) {
        if (_gen >= 1 || _gen <= 2) {
            return 2 + uint8(_rand) % 3;  
        } else if (_gen >= 3 || _gen <= 8) {
            return 2 + uint8(_rand) % 2;  
        }  else if (_gen >= 9 || _gen <= 15) {
            return 1 + uint8(_rand) % 3;  
        } else {  
            return 1 + uint8(_rand) % 2;  
        }
    }

    function raceToBaseStats(uint _race) public view returns (
        uint8 strength,
        uint8 dexterity,
        uint8 vitality
    ) {
         
        if (_race >= raceBaseStats.length) {
            _race = 0;
        }

        RaceBaseStats memory raceStats = raceBaseStats[_race];

        strength = raceStats.strength;
        dexterity = raceStats.dexterity;
        vitality = raceStats.vitality;
    }

    function genToExtraStats(uint256 _gen, uint256 _rand) public view returns (
        uint8 extraStrength,
        uint8 extraDexterity,
        uint8 extraVitality
    ) {
         
        if (_gen >= 10) {
            _gen = 10;
        }

        uint8 extraStats = extraStatsForGen[_gen];

        uint256 rand1 = _rand & 0xff;
        uint256 rand2 = _rand >> 16 & 0xff;
        uint256 rand3 = _rand >> 16 >> 16 & 0xff;

        uint256 sum = rand1 + rand2 + rand3;

        extraStrength = uint8((extraStats * rand1) / sum);
        extraDexterity = uint8((extraStats * rand2) / sum);
        extraVitality = uint8((extraStats * rand3) / sum);

        uint8 remainder = extraStats - (extraStrength + extraDexterity + extraVitality);

        if (rand1 > rand2 && rand1 > rand3) {
            extraStrength += remainder;
        } else if (rand2 > rand3) {
            extraDexterity += remainder;
        } else {
            extraVitality += remainder;
        }
    }

    function _getStrengthDexterityVitality(uint256 _race, uint256 _generation, uint256 _rand) public view returns (
        uint256 strength,
        uint256 dexterity,
        uint256 vitality
    ) {
        uint8 baseStrength;
        uint8 baseDexterity;
        uint8 baseVitality;
        uint8 extraStrength;
        uint8 extraDexterity;
        uint8 extraVitality;

        (baseStrength, baseDexterity, baseVitality) = raceToBaseStats(_race);
        (extraStrength, extraDexterity, extraVitality) = genToExtraStats(_generation, _rand);

        strength = baseStrength + extraStrength;
        dexterity = baseDexterity + extraDexterity;
        vitality = baseVitality + extraVitality;
    }

     
     
    function _generateFighterStats(uint256 generation1, uint256 genes1, uint256 generation2, uint256 genes2) internal returns (uint256[6]) {
         
         
         
         

        uint256 generation256 = ((generation1 + generation2) / 2) + 1;

         
        if (generation256 > 65535)
            generation256 = 65535;
        
        uint16 generation = uint16(generation256);

        uint256 genes = geneScience.mixGenes(genes1, genes2);

        uint256 strength;
        uint256 dexterity;
        uint256 vitality;

        uint256 rand = uint(keccak256(now, msg.sender, randomCounter++));

        (strength, dexterity, vitality) = _getStrengthDexterityVitality(_getRaceFromGenes(genes), generation, rand);

        uint256 luck = genToLuck(genes, rand);

        return [
            generation,
            genes,
            strength,
            dexterity,
            vitality,
            luck
        ];
    }

     
     
     
     
    function _getRaceFromGenes(uint256 _genes) internal pure returns (uint256) {
        return (_genes >> (16)) & 0xff;
    }

    function experienceToLevel(uint256 _experience) public view returns (uint256) {
        for (uint256 i = 0; i < stats.length; i++) {
            if (stats[i] > _experience) {
                 
                return i;
            }
        }

        return 50;
    }

     
     
     
     
     
     
    function _calculateNewStat(uint32 _currentExperience, uint32 _newExperience) internal returns (uint256) {
         
        for (uint256 i = 0; i < stats.length; i++) {
            if (stats[i] > _currentExperience) {
                 
                if (stats[i] <= _newExperience) {
                     
                    return 1 + randMod(randomCounter++, 4);
                } else {
                    return 0;
                }
            }
        }

         
        return 0;
    }

     
     
     
     
     
     

    function _getFighterStatsData(uint256 _fighterId) internal view returns (uint256[6]) {
        uint256 dexterity;
        uint256 strength;
        uint256 vitality;
        uint256 luck;
        uint256 experience;
        uint256 battleCooldownEndTime;
        
        (
            ,
            battleCooldownEndTime,
            ,
            ,
            ,
            ,
            ,
            dexterity,
            strength,
            vitality,
            luck,
            experience
        ) = fighterCore.getFighter(_fighterId);

        return [
            dexterity,
            strength,
            vitality,
            luck,
            experience,
            battleCooldownEndTime
        ];
    }

    function _getFighterBattleData(uint256 _fighterId) internal view returns (uint256[7]) {
        uint256 prizeCooldownEndTime;
        uint256 prizeCooldownIndex;
        uint256 battleCooldownEndTime;
        uint256 battlesFought;
        uint256 battlesWon;
        uint256 generation;
        uint256 genes;
        
        (
            prizeCooldownEndTime,
            battleCooldownEndTime,
            prizeCooldownIndex,
            battlesFought,
            battlesWon,
            generation,
            genes,
            ,
            ,
            ,
            ,
        ) = fighterCore.getFighter(_fighterId);

        return [
            prizeCooldownEndTime,
            prizeCooldownIndex,
            battleCooldownEndTime,
            battlesFought,
            battlesWon,
            generation,
            genes
        ];
    }

    function _increaseFighterStats(
        uint256 _fighterId,
        uint32 _experienceGained,
        uint[6] memory data
    ) internal {
         
        if (data[5] >= block.number) {
            return;
        }

        uint32 experience = uint32(data[4]);
        uint32 newExperience = experience + _experienceGained;
        uint256 _statIncrease = _calculateNewStat(experience, newExperience);
        
        fighterCore.updateExperience(_fighterId, newExperience);

        if (_statIncrease == 1) {
            fighterCore.updateDexterity(_fighterId, uint8(++data[0]));
        } else if (_statIncrease == 2) {
            fighterCore.updateStrength(_fighterId, uint8(++data[1]));
        } else if (_statIncrease == 3) {
            fighterCore.updateVitality(_fighterId, uint8(++data[2]));
        } else if (_statIncrease == 4) {
            fighterCore.updateLuck(_fighterId, uint8(++data[3]));
        }
    }

    function _increaseTeamFighterStats(uint256[] memory _fighterIds, uint32 _experienceGained) private {
        for (uint i = 0; i < _fighterIds.length; i++) {
            _increaseFighterStats(_fighterIds[i], _experienceGained, _getFighterStatsData(_fighterIds[i]));
        }
    }

    function _updateFighterBattleStats(
        uint256 _fighterId,
        bool _winner,
        bool _leader,
        uint[7] memory data,
        bool _skipAwardPrize
    ) internal {
        uint64 prizeCooldownEndTime = uint64(data[0]);
        uint16 prizeCooldownIndex = uint16(data[1]);
        uint64 battleCooldownEndTime = uint64(data[2]);
        uint16 updatedBattlesFought = uint16(data[3]) + 1;

         
        if (_winner && _leader && !_skipAwardPrize) {
            prizeCooldownEndTime = uint64((prizeCooldowns[prizeCooldownIndex] / secondsPerBlock) + block.number);

            if (prizeCooldownIndex < 6) {
               prizeCooldownIndex += 1;
            }
        }

        if (updatedBattlesFought % battlesTillBattleCooldown == 0) {
            battleCooldownEndTime = uint64((experienceDelay / secondsPerBlock) + block.number);
        }

        fighterCore.updateFighterBattleStats(
            _fighterId,
            prizeCooldownEndTime,
            prizeCooldownIndex,
            battleCooldownEndTime,
            updatedBattlesFought,
            uint16(data[4]) + (_winner ? 1 : 0)  
        );
    }

    function _updateTeamBattleStats(uint256[] memory _fighterIds, bool _attackerWin, bool _skipAwardPrize) private {
        for (uint i = 0; i < _fighterIds.length; i++) {
            _updateFighterBattleStats(_fighterIds[i], _attackerWin, i == 0, _getFighterBattleData(_fighterIds[i]), _skipAwardPrize);
        }
    }

    function _awardPrizeFighter(
        address _winner, uint256[7] _attackerLeader, uint256[7] _defenderLeader
    )
        internal
        returns (uint16 prizeGen, uint256 prizeGenes)
    {
        uint256[6] memory newFighterData = _generateFighterStats(_attackerLeader[5], _attackerLeader[6], _defenderLeader[5], _defenderLeader[6]);

        prizeGen = uint16(newFighterData[0]);
        prizeGenes = newFighterData[1];

        fighterCore.createPrizeFighter(
            prizeGen,
            prizeGenes,
            uint8(newFighterData[2]),
            uint8(newFighterData[3]),
            uint8(newFighterData[4]),
            uint8(newFighterData[5]),
            _winner
        );
    }

    function _updateFightersAndAwardPrizes(
        uint256[] _attackerFighterIds,
        uint256[] _defenderFighterIds,
        bool _attackerWin,
        address _winnerAddress,
        uint32 _attackerExperienceGained,
        uint32 _defenderExperienceGained
    )
        internal
        returns (uint16 prizeGen, uint256 prizeGenes)
    {
         
        uint256[7] memory attackerLeader = _getFighterBattleData(_attackerFighterIds[0]);
        uint256[7] memory defenderLeader = _getFighterBattleData(_defenderFighterIds[0]);

        bool skipAwardPrize = (_attackerWin && attackerLeader[0] >= block.number) || (!_attackerWin && defenderLeader[0] >= block.number);
        
        _increaseTeamFighterStats(_attackerFighterIds, _attackerExperienceGained);
        _increaseTeamFighterStats(_defenderFighterIds, _defenderExperienceGained);
        
        _updateTeamBattleStats(_attackerFighterIds, _attackerWin, skipAwardPrize);
        _updateTeamBattleStats(_defenderFighterIds, !_attackerWin, skipAwardPrize);
        
         

         
        if (skipAwardPrize) {
            return;
        }

        return _awardPrizeFighter(_winnerAddress, attackerLeader, defenderLeader);
    }
}

 

contract BattleCore is BattlePrize {
    function BattleCore(address _coreAddress, address _geneScienceAddress, address _battleDeciderAddress) public {
        addRace(4, 4, 4);  
        addRace(6, 2, 4);  
        addRace(4, 5, 3);  
        addRace(6, 4, 2);  
        addRace(7, 1, 4);

        _setFighterCoreAddress(_coreAddress);
        _setGeneScienceAddress(_geneScienceAddress);
        _setBattleDeciderAddress(_battleDeciderAddress);
        
         
        uint256[] memory fighterIds = new uint256[](1);
        fighterIds[0] = uint256(0);
        _createTeam(address(0), fighterIds);
        teamIndexToExist[0] = false;
    }

     
    function() external {}
    
    function totalTeams() public view returns (uint256) {
         
        return teams.length - 1;
    }
    
    function isValidTeam(uint256[] _fighterIds) public view returns (bool) {
        for (uint i = 0; i < _fighterIds.length; i++) {
            uint256 fighterId = _fighterIds[i];
            if (fighterCore.ownerOf(fighterId) != msg.sender)
                return false;
            if (fighterIndexToTeam[fighterId] > 0)
                return false;

             
            for (uint j = i + 1; j < _fighterIds.length; j++) {
                if (_fighterIds[i] == _fighterIds[j]) {
                    return false;            
                }
            }
        }
        
        return true;
    }
    
    function createTeam(uint256[] _fighterIds)
        public
        whenNotPaused
        returns(uint256)
    {
        require(_fighterIds.length > 0 && _fighterIds.length <= maxPerTeam);
        
        require(isValidTeam(_fighterIds));

        return _createTeam(msg.sender, _fighterIds);
    }
    
    function _createTeam(address _owner, uint256[] _fighterIds) internal returns(uint256) {
        Team memory _team = Team({
            owner: _owner,
            fighterIds: _fighterIds
        });

        uint256 newTeamId;

         
        if (deletedTeamIds.length > 0) {
            newTeamId = deletedTeamIds[deletedTeamIds.length - 1];
            delete deletedTeamIds[deletedTeamIds.length - 1];
            deletedTeamIds.length--;
            teams[newTeamId] = _team;
        } else {
            newTeamId = teams.push(_team) - 1;
        }

        require(newTeamId <= 4294967295);

        for (uint i = 0; i < _fighterIds.length; i++) {
            uint256 fighterId = _fighterIds[i];

            fighterIndexToTeam[fighterId] = newTeamId;
        }

        teamIndexToExist[newTeamId] = true;

        TeamCreated(newTeamId, _fighterIds);

        return newTeamId;
    }

    function deleteTeam(uint256 _teamId)
        public
        whenNotPaused
        onlyTeamOwner(_teamId)
        onlyExistingTeam(_teamId)
    {
        _deleteTeam(_teamId);
    }

    function _deleteTeam(uint256 _teamId) private {
        Team memory team = teams[_teamId];

        for (uint256 i = 0; i < team.fighterIds.length; i++) {
            fighterIndexToTeam[team.fighterIds[i]] = 0;
        }

        TeamDeleted(_teamId, team.fighterIds);

        delete teams[_teamId];

        deletedTeamIds.push(_teamId);
        
        teamIndexToExist[_teamId] = false;
    }

    function battle(uint256[] _attackerFighterIds, uint256 _defenderTeamId)
        public
        whenNotPaused
        onlyExistingTeam(_defenderTeamId)
        returns (bool)
    {
        require(_attackerFighterIds.length > 0 && _attackerFighterIds.length <= maxPerTeam);
        require(isValidTeam(_attackerFighterIds));

        Team memory defenderTeam = teams[_defenderTeamId];

         
        require(msg.sender != defenderTeam.owner);

        uint256[] memory defenderFighterIds = defenderTeam.fighterIds;
        
        bool attackerWon;
        uint256 xpForAttacker;
        uint256 xpForDefender;

        _deleteTeam(_defenderTeamId);

        (
            attackerWon,
            xpForAttacker,
            xpForDefender
        ) = battleDecider.determineWinner(getFighterArray(_attackerFighterIds), getFighterArray(defenderFighterIds));
        
        address winnerAddress;
        address loserAddress;

        if (attackerWon) {
            winnerAddress = msg.sender;
            loserAddress = defenderTeam.owner;
        } else {
            winnerAddress = defenderTeam.owner;
            loserAddress = msg.sender;
        }
        
        uint16 prizeGen;
        uint256 prizeGenes;
        (prizeGen, prizeGenes) = _updateFightersAndAwardPrizes(_attackerFighterIds, defenderFighterIds, attackerWon, winnerAddress, uint32(xpForAttacker), uint32(xpForDefender));
        
        BattleResult(winnerAddress, loserAddress, _attackerFighterIds, defenderFighterIds, attackerWon, prizeGen, prizeGenes, uint32(xpForAttacker), uint32(xpForDefender));

        return attackerWon;
    }
        
     
    function getTeam(uint256 _id)
        public
        view
        returns (
        address owner,
        uint256[] fighterIds
    ) {
        Team storage _team = teams[_id];

        owner = _team.owner;
        fighterIds = _team.fighterIds;
    }

    function getFighterArray(uint256[] _fighterIds) public view returns (uint256[7][]) {
        uint256[7][] memory res = new uint256[7][](_fighterIds.length);

        for (uint i = 0; i < _fighterIds.length; i++) {
            uint256 generation;
            uint256 genes;
            uint256 dexterity;
            uint256 strength;
            uint256 vitality;
            uint256 luck;
            uint256 experience;
            
            (
                ,
                ,
                ,
                ,
                ,
                generation,
                genes,
                dexterity,
                strength,
                vitality,
                luck,
                experience
            ) = fighterCore.getFighter(_fighterIds[i]);

            uint256 level = experienceToLevel(experience);

            res[i] = [
                level,
                generation,
                strength,
                dexterity,
                vitality,
                luck,
                genes
            ];
        }

        return res;
    }
}