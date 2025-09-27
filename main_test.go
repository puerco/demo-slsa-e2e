// SPDX-FileCopyrightText: Copyright 2025 Carabiner Systems, Inc
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestIsItFriday(t *testing.T) {
	t.Parallel()
	for _, tt := range []struct {
		name     string
		time     string
		isFriday bool
	}{
		{"friday", "2025-09-26T10:30:00Z", true},
		{"not-friday", "2025-09-24T10:30:00Z", false},
	} {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			tRFC, err := time.Parse(time.RFC3339, tt.time)
			require.NoError(t, err)
			require.Equal(t, tt.isFriday, IsItFriday(tRFC))
		})
	}
}
