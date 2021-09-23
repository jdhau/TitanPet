// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";

contract TitanPet is Ownable{
    
    enum attr {
        HUNGER,
        THIRST,
        UNHEALTHINESS,
        UNHAPPINESS,
        TIREDNESS,
        DIRTINESS
    }
    
    // Stats mapping
    mapping(attr=>int) attributes;
    // Attribute update timestamps
    mapping(attr=>uint) attributeChanges;
    
    // Status and attributes
    string name;
    string eulogy;
    bool asleep;
    bool buried;
    
    // Timestamps
    uint bornTimestamp;
    uint buriedTimestamp;
    uint sleepTime;
    uint wakeUpTime;
    
    modifier onlyDead() {
        require(!isAlive(), "I'm alive");
        _;
    }
    
    modifier onlyAlive() {
        require(isAlive(), "Dead. RIP.");
        _;
    }
    
    modifier onlyAwake() {
        require(!asleep, "I'm asleep");
        _;
    }
    
    modifier onlyAsleep() {
        require(asleep, "I'm awake");
        _;
    }
    
    event Born(uint256 timeStamp);
    event ThankYou(address who, uint256 amount);
    
    constructor(string memory p_name) {
        name = p_name;
        attributes[attr.HUNGER] = 0;
        attributes[attr.THIRST] = 0;
        attributes[attr.UNHEALTHINESS] = int(block.timestamp ^ block.difficulty) % 40;
        attributes[attr.UNHAPPINESS] = int(block.timestamp) % 40;
        attributes[attr.TIREDNESS] = 0;
        attributes[attr.DIRTINESS] = int(block.timestamp ^ block.number) % 40;
        asleep = false;
        buried = false;
        bornTimestamp = block.timestamp;
        emit Born(block.timestamp);
    }
    
    /* INTERACTIONS */
    function buyApple() external onlyAwake onlyAlive onlyOwner{
        require (getDirtiness()>=30,"I'm too dirty to eat");
        require (getHunger()>=30,"I'm not hungry");
        setAttr(attr.HUNGER,getHunger()-20);
        setAttr(attr.THIRST,getThirst()-10);
        setAttr(attr.DIRTINESS,getDirtiness()+15);
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-10);
    }
    
    function buyCake() external onlyAwake onlyAlive onlyOwner{
        require (getHunger()>=30,"I'm stuffed!");
        require (getDirtiness()>=30,"I'm too dirty to eat!");
        setAttr(attr.UNHAPPINESS,getUnHappiness()+ 10 + getHunger()/10);
        setAttr(attr.HUNGER,getHunger()-30);
        setAttr(attr.THIRST,getThirst()+10);
        setAttr(attr.DIRTINESS,getDirtiness()+20);
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()+10);
        setAttr(attr.TIREDNESS,getTiredness()+10);
    }
    
    function buyVegetables() external onlyAwake onlyAlive onlyOwner{
        require (getDirtiness()>=30,"I'm too dirty to eat");
        require (getHunger()>=30,"I'm stuffed!");
        setAttr(attr.HUNGER,getHunger()-20);
        setAttr(attr.DIRTINESS,getDirtiness()+10);
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-15);
        setAttr(attr.UNHAPPINESS,getUnHappiness()+10);
    }
    
    function buyMeal() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.HUNGER,0);
        setAttr(attr.THIRST,getThirst()/2);
        setAttr(attr.DIRTINESS,getDirtiness()+15);
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-10);
        setAttr(attr.UNHAPPINESS,getUnHappiness()-getHunger()/10);
    }
    
    function buyWater() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.UNHAPPINESS,getUnHappiness()-getThirst()/10);
        setAttr(attr.THIRST,getThirst()-50);
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-10);
    }

    function buySoda() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.UNHAPPINESS,getUnHappiness()-(15 + getThirst()/10));
        setAttr(attr.HUNGER,getHunger()-10);
        setAttr(attr.THIRST,getThirst()-50);
        setAttr(attr.DIRTINESS,getDirtiness()+15);
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()+10);
        setAttr(attr.TIREDNESS,getTiredness()+5);
    }

    function buyFruitJuice() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.UNHAPPINESS,getUnHappiness()-(5 + getThirst()/10));
        setAttr(attr.HUNGER,getHunger()-10);
        setAttr(attr.THIRST,getThirst()-30);
        setAttr(attr.DIRTINESS,getDirtiness()+10);
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-15);
        setAttr(attr.TIREDNESS,getTiredness()+5);
    }
    
    function buyToy() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.UNHAPPINESS,getUnHappiness()-50);
        setAttr(attr.TIREDNESS,getTiredness()+20);
        setAttr(attr.DIRTINESS,getDirtiness()+20);
    }
    
    function buyMedicine() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-50);
        setAttr(attr.UNHAPPINESS,getUnHappiness()+30);
        setAttr(attr.TIREDNESS,getTiredness()+30);
    }
    
    function brush() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.DIRTINESS,getDirtiness()-20);
        setAttr(attr.UNHAPPINESS,getUnHappiness()+10);
    }
    
    function wash() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.DIRTINESS,getDirtiness()-50);
        setAttr(attr.UNHAPPINESS,getUnHappiness()+20);
          setAttr(attr.TIREDNESS,getTiredness()+10);     
    }
    
    function walk() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-15);
        setAttr(attr.UNHAPPINESS,getUnHappiness()-10);
        setAttr(attr.TIREDNESS,getTiredness()+20);
    }
    
    function exercise() external onlyAwake onlyAlive onlyOwner{
        setAttr(attr.UNHEALTHINESS,getUnHealthiness()-25);
        setAttr(attr.UNHAPPINESS,getUnHappiness()-10);
        setAttr(attr.TIREDNESS,getTiredness()+30);
        setAttr(attr.THIRST,getThirst()+30); // require thirst <70 so you cant exercise to death (goes for other stuff too) 
    }
    
    function sleep() external onlyAwake onlyAlive onlyOwner{
        require (getTiredness()>=75, "I'm not sleepy");
        sleepTime = block.timestamp;
        asleep = true;
    }
    
    function wakeUp() external onlyAsleep onlyAlive onlyOwner{
        require (asleep, "I'm already awake");
        require ((block.timestamp - sleepTime) > 30 minutes, "ZzzZzzz...");
        wakeUpTime = block.timestamp;
        
        // Underslept
        if ((wakeUpTime - sleepTime) > 30 minutes && (wakeUpTime - sleepTime) <= 1 hours) {
            setAttr(attr.TIREDNESS,20+int(wakeUpTime % 50));
            setAttr(attr.UNHAPPINESS,getUnHappiness()+20);
            setAttr(attr.UNHEALTHINESS,getUnHealthiness()+10);
        }
        
        // Slept okay
        if ((wakeUpTime - sleepTime) > 1 hours && (wakeUpTime - sleepTime) <= 2 hours) {
            setAttr(attr.TIREDNESS,10+int(wakeUpTime % 30));
        }
        
        // Well slept
        if ((wakeUpTime - sleepTime) > 2 hours) {
            setAttr(attr.TIREDNESS,int(wakeUpTime) % 20);
            setAttr(attr.UNHAPPINESS,getUnHappiness()-20);
            setAttr(attr.UNHEALTHINESS,getUnHealthiness()-10);
        }

    }

    // Param has to be an int to prevent possible underflow
    function setAttr(attr p_attribute, int p_value) internal {
        if (p_value<0) {
            p_value=0;
        }
        if (p_value>100) {
            p_value=100;
        }
        attributes[p_attribute] = p_value;
        attributeChanges[p_attribute] = block.timestamp;
    }

    
    // Get functions
    function getHunger() public view returns(int){
        if (asleep){
            return attributes[attr.HUNGER];
        }
        else {
            // time decay function
            return attributes[attr.HUNGER];
        }
    }
    
    function getThirst() public view returns(int){
        if (asleep){
            return attributes[attr.THIRST];
        }
        else {
            // time decay function
            return attributes[attr.THIRST];
        }
    }
    
    function getDirtiness() public view returns(int){
        if (asleep){
            return attributes[attr.DIRTINESS];
        }
        else {
            // time decay function
            return attributes[attr.DIRTINESS];
        }
    }
 
    function getUnHappiness() public view returns(int){
        return attributes[attr.UNHAPPINESS];
    }   
    
    function getMinutesAsleep() public view onlyAsleep returns(uint) {
        return (block.timestamp-sleepTime)/1 minutes;
    }
    
    function getTiredness() public view returns(int){
        return attributes[attr.TIREDNESS];
    }
    
    function getUnHealthiness() public view returns(int){
        return (100-attributes[attr.UNHEALTHINESS]);
    }
    
    function getEulogy() public view returns(string memory){
        return eulogy;
    }
    
    function isBuried() external view returns(bool){
        return buried;
    }
    
    function isAlive() public view returns(bool){
        return (getHunger() < 100 
        && getThirst() < 100 
        && getUnHealthiness() > 0);
    }
    
    function bury(string calldata p_eulogy) external onlyDead onlyOwner{
        require (!buried);
        buried = true;
        buriedTimestamp = block.timestamp;
        eulogy = p_eulogy;
    }
    
    function revive() external onlyDead onlyOwner{
        attributes[attr.UNHEALTHINESS]=100;
    }
    
    function kill() external onlyAlive {
        attributes[attr.UNHEALTHINESS]=0;
    }
    
}