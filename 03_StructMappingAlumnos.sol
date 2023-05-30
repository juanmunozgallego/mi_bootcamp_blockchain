// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

contract CursoBlockchain {
    
    address[] public listaAlumnos;                             
    uint8 public maxAlumnos = 10; 
    address public profesor;
    uint256 private _precioCurso;
    
    //Clave (alumno) --> Valor (nota)
    
    mapping(address => uint16) private calificaciones;    
    
    struct Alumno {
        string nickName;
        uint256 calificacion;
        bool activo;
        address alumno;
        uint8 orden;
    }

    mapping(uint8 => Alumno) private alumnosByOrden;
    mapping(address => Alumno) private alumnosByAddress;
    
    uint8 public numAlumnos;


    modifier onlyProfesor {
        require( msg.sender == profesor, "Tu address no esta autorizada como profesor." );
        _;
    }

    constructor(){
        profesor = msg.sender;
        _precioCurso = 100;        
    }

//public functions
    function registroAlumno() external payable returns(bool) {
        require(msg.value == _precioCurso,"Debes pagar 100 weis por apuntarte.");
        _addAlumno(msg.sender);

        (bool sentValue, ) = payable(profesor).call{value: _precioCurso}("");
        require(sentValue, "El ETH no se ha podido enviar.");

        return true;
    }

    function registroAlumnoM(string memory nick) external payable returns(bool) {
        require(msg.value == _precioCurso,"Debes pagar 100 weis por apuntarte.");
        _addAlumnoM(msg.sender, nick);

        (bool sentValue, ) = payable(profesor).call{value: _precioCurso}("");
        require(sentValue, "El ETH no se ha podido enviar.");

        return true;
    }

    //Añadir un nuevo alumno (identificado por su address)
    //Devuelve el número actual de alumnos
    function _addAlumno(address alumno) 
        private  
        returns(bool) {        
        
        listaAlumnos.push(alumno);        
        return true;
    }

    function _addAlumnoM(address alumno, string memory nick) 
        private  
        returns(bool) {        
        
        //listaAlumnos.push(alumno);        
        numAlumnos++;
        Alumno memory alumnoStruct = Alumno(nick, 0, true, alumno, numAlumnos);
        
        alumnosByOrden[numAlumnos] = alumnoStruct;
        alumnosByAddress[alumno] = alumnoStruct;

        return true;
    }

    function claimMoney() external returns(bool){
        uint256 balance = address(this).balance;
        (bool sentValue, ) = payable(profesor).call{value: balance}("");
        require(sentValue, "El ETH no se ha podido enviar.");
        return sentValue;
    }

    receive() external payable {
        (bool sent, ) = payable(msg.sender).call{value: msg.value}("");
        require(sent, "El ETH no se ha podido enviar.");
    }


//Admin functions

    //Calificar a un alumno
    function calificarAlumno(address alumno, uint16 nota) external onlyProfesor 
        returns (bool) {
            require(checkIfAlumnoExists(alumno), "El alumno no existe.");
            calificaciones[alumno] = nota;
            return true;
    }

    //Calificar a un alumno
    function calificarAlumnoM(address alumno, uint16 nota) external onlyProfesor 
        returns (bool) {
            require(checkIfAlumnoExistsM(alumno), "El alumno no existe.");
            calificaciones[alumno] = nota;
            return true;
    }

    function consultarCalificacion(address alumno) public view returns(uint16) {
        return calificaciones[alumno];
    }

     function consultarCalificacionM(address alumno) public view returns(uint256) {
        return alumnosByAddress[alumno].calificacion;
    }

    function consultarMiCalificacion() public view returns(uint16) {
        return calificaciones[msg.sender];
    }



    function eliminarAlumno(address alumno) external onlyProfesor 
        returns(bool){
        
        //Comprobamos si el alumno existe
        if (checkIfAlumnoExists(alumno)){  
            //Encontrar la posición en la que se encuentra el alumno
            uint8 position = findAlumnoPosition(alumno);

            //Eliminar position de listaAlumnos
            for(uint8 i = position; i < listaAlumnos.length; i++){
                listaAlumnos[i] = listaAlumnos[i + 1];       
            }
            listaAlumnos.pop();
            return true;
        }
        else {
            return false;
        }

    }

    function editAddressAlumno(address oldAddr, address newAddr) public onlyProfesor returns (bool){
        
        if (checkIfAlumnoExists(oldAddr)){
            //Obtener la posición en la que se encuentra oldAddr
            uint8 position = findAlumnoPosition(oldAddr);

            //Reemplaza el valor de oldAddr por newAddr
            listaAlumnos[position] = newAddr;
            return true;
        }
        else {
            return false;
        }
        
    }

    function editAlumnoAddress(uint8 position, address newValue) onlyProfesor public 
    returns(bool){              
        listaAlumnos[position] = newValue;
        return true;
    }

    //Devuelve la lista completa de alumnos (la address)
    function getAlumnos() public view returns(address[] memory){        
        return listaAlumnos;
    } 

    //Devuelve el número de alumnos apuntados
    function getNumAlumnos() external view returns(uint256){
        return listaAlumnos.length;
    }

    function getNumAlumnosM() external view returns(uint256){
        return numAlumnos;
    }

    //Comprueba si el alumno está en la lista
    function checkIfAlumnoExists(address alumno) public view returns (bool){
        uint8 i;
        while(i < listaAlumnos.length){
            if(listaAlumnos[i] == alumno){
                return true;
            }
            else {
                i++;
            }
        }
        return false;
    }

        //Comprueba si el alumno está en la lista
    function checkIfAlumnoExistsM(address alumnoAddr) public view returns (bool){
       
        if(alumnosByAddress[alumnoAddr].alumno == address(0)){
            return false;
        }
        else {
            return true;
        }
       
    }

    //Obtener la posición de la lista en la que se encuentra un alumno
    function findAlumnoPosition(address alumno) public view returns(uint8){
        for(uint8 i; i < listaAlumnos.length; i++){
            if(listaAlumnos[i] == alumno){                 
               return i;              
            }
        }
    }

    //Obtener el alumno que se apuntó en el orden "position"
    function getAlumnoByOrden(uint8 position) public view returns(address){        
        return listaAlumnos[position];
    }

 

 
}





    /*
        0 --> aaa
        1 --> bbb
        2 --> ccc
        3 --> ddd
        4 --> eee
    */




/*
    listaAlumnos:
    0 -->   0x772d0C21EBAB38c34000AB725d33B919c21C0aD3,
    1 -->   0xf0098aa5B725e654e1026f3B2e4b6b606E770770,
    2 -->   0xFC9161b4cA1E5DB6FEcf7d914a73c95ac969B7B9
    3 -->   0x0000000000000000000000000000000000000000
    length = 4
*/
