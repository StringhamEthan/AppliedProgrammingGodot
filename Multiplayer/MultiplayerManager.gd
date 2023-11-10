extends Node

var peer
var Players = {}
var LocalPlayerName
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

#only called on clients
func connection_failed():
	print("connection failed")

#called on clients
func connected_to_server():
	print("connected to server!")
	SendPlayerInformation.rpc_id(1,LocalPlayerName,multiplayer.get_unique_id())

@rpc("any_peer")
func SendPlayerInformation(Name,id):
	if !Players.has(id):
		Players[id]={
			"Name": Name,
			"id": id,
			"Score": 0
		}
	if multiplayer.is_server():
		for i in Players:
			SendPlayerInformation.rpc(Players[i].Name,i)
#called on clients and server
func peer_connected(id):
	print("peer connnected: " + str(id))

#called on server and clients
func peer_disconnected(id):
	print("peer disconnected: " + str(id))

func BeginHosting(NewName,Port):
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(int(Port),32)
	if error != OK:
		print("Cannot Host: " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players")
	SendPlayerInformation(NewName,multiplayer.get_unique_id())
	
func JoinGame(NewName,Address,Port):
	LocalPlayerName = NewName
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address,int(Port))
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
