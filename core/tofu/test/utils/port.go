package utils

import (
	"net"
	"testing"

	"github.com/stretchr/testify/require"
)

func GetAvailablePort(t *testing.T) int {
	listener, err := net.Listen("tcp", ":0")
	require.NoError(t, err, "Failed to find available port")

	port := listener.Addr().(*net.TCPAddr).Port

	listener.Close()
	t.Logf("Using OS-assigned available port: %d", port)

	return port
}
