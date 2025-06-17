// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CovidMedicalRecord {
    struct Patient {
        string name;
        string birthPlaceDate;
        uint8 age;
        string gender;
        string phoneNumber;
        string vaccinationStatus;
    }

    struct Covid19Record {
        uint256 recordID;
        string hospitalName;
        string testResult;
        string doctorName;
        string treatment;
        string treatmentNotes;
        string medicineNotes;
        string doctorNotes;
        uint256 timestamp;
        address hospitalPubKey;
    }

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only system owner allowed");
        _;
    }

    modifier onlyAuthorized(address patient) {
        require(authorizedProviders[msg.sender], "Not an authorized provider");
        require(accessControl[patient][msg.sender], "Access not granted by patient");
        _;
    }

    mapping(address => Patient) public patients;
    mapping(address => Covid19Record[]) private patientRecords;
    mapping(address => mapping(address => bool)) public accessControl;
    mapping(address => bool) public authorizedProviders;
    mapping(address => string) public hospitalPublicKeys;
    address[] public providerList;

    event ProviderAuthorized(address indexed provider);
    event AccessGranted(address indexed patient, address indexed provider);
    event AccessRevoked(address indexed patient, address indexed provider);
    event RecordAdded(address indexed patient, uint256 indexed recordID);
    event RecordDeleted(address indexed patient, uint256 indexed recordID);

    // Register patient profile
    function setPatientProfile(
        string memory _name,
        string memory _birthPlaceDate,
        uint8 _age,
        string memory _gender,
        string memory _phoneNumber,
        string memory _vaccinationStatus
    ) public {
        require(bytes(patients[msg.sender].name).length == 0, "Patient already registered");

        patients[msg.sender] = Patient(
            _name,
            _birthPlaceDate,
            _age,
            _gender,
            _phoneNumber,
            _vaccinationStatus
        );
    }

    // Owner authorizes a provider
    function authorizeProvider(address provider) public onlyOwner {
        require(provider != address(0), "Invalid provider address");
        if (!authorizedProviders[provider]) {
            authorizedProviders[provider] = true;
            providerList.push(provider);
            emit ProviderAuthorized(provider);
        }
    }

    // Patient grants access to a provider
    function grantAccessToProvider(address provider) external {
        require(provider != address(0), "Invalid provider address");
        accessControl[msg.sender][provider] = true;

        if (!authorizedProviders[provider]) {
            authorizedProviders[provider] = true;
            providerList.push(provider);
            emit ProviderAuthorized(provider);
        }

        emit AccessGranted(msg.sender, provider);
    }

    // Patient revokes access from a provider
    function revokeAccessFromProvider(address provider) external {
        require(provider != address(0), "Invalid provider address");
        accessControl[msg.sender][provider] = false;
        emit AccessRevoked(msg.sender, provider);
    }

    // Authorized provider adds record to patient
    function addRecord(
        string memory hospitalName,
        string memory testResult,
        string memory doctorName,
        string memory treatment,
        string memory treatmentNotes,
        string memory medicineNotes,
        string memory doctorNotes,
        address patient
    ) public  {
        uint256 recordID = patientRecords[patient].length + 1;

        Covid19Record memory newRecord = Covid19Record(
            recordID,
            hospitalName,
            testResult,
            doctorName,
            treatment,
            treatmentNotes,
            medicineNotes,
            doctorNotes,
            block.timestamp,
            msg.sender
        );

        patientRecords[patient].push(newRecord);
        emit RecordAdded(patient, recordID);
    }

    // Authorized provider gets patient records
    function getRecords(address patient) public view returns (Covid19Record[] memory) {
        return patientRecords[patient];
    }

    // Authorized provider deletes a patient record
    function deleteRecord(address patient, uint256 index) public {
        require(index < patientRecords[patient].length, "Invalid index");

        for (uint256 i = index; i < patientRecords[patient].length - 1; i++) {
            patientRecords[patient][i] = patientRecords[patient][i + 1];
        }
        patientRecords[patient].pop();

        emit RecordDeleted(patient, index + 1);
    }

    // Patient reads their own profile
    function getMyProfile() public view returns (
        string memory name,
        string memory birthPlaceDate,
        uint8 age,
        string memory gender,
        string memory phoneNumber,
        string memory vaccinationStatus
    ) {
        Patient memory p = patients[msg.sender];
        return (
            p.name,
            p.birthPlaceDate,
            p.age,
            p.gender,
            p.phoneNumber,
            p.vaccinationStatus
        );
    }

    // Patient sees all providers they've granted access to
    function getMyGrantedProviders() public view returns (address[] memory) {
        uint count = 0;
        for (uint i = 0; i < providerList.length; i++) {
            if (accessControl[msg.sender][providerList[i]]) {
                count++;
            }
        }

        address[] memory result = new address[](count);
        uint index = 0;
        for (uint i = 0; i < providerList.length; i++) {
            if (accessControl[msg.sender][providerList[i]]) {
                result[index] = providerList[i];
                index++;
            }
        }

        return result;
    }
}
