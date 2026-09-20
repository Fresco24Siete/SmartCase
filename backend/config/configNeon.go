package config

import (
	"fmt"
	"os"

	"github.com/jmoiron/sqlx"
	"github.com/joho/godotenv"

	_ "github.com/jackc/pgx/v5/stdlib"
)

func LoadConfigNeon() (*sqlx.DB, error) {
	if os.Getenv("RENDER") == "" {
		_ = godotenv.Load("../../.env")
		_ = godotenv.Load(".env")
	}

	connStr := os.Getenv("DATABASE_URL")
	if connStr == "" {
		host := os.Getenv("DB_Host")
		if host == "" {
			host = os.Getenv("DB_HOST")
		}
		port := os.Getenv("DB_Port")
		if port == "" {
			port = os.Getenv("DB_PORT")
		}
		if port == "" {
			port = "5432"
		}
		user := os.Getenv("DB_User")
		if user == "" {
			user = os.Getenv("DB_USER")
		}
		password := os.Getenv("DB_Password")
		if password == "" {
			password = os.Getenv("DB_PASSWORD")
		}
		dbname := os.Getenv("DB_Name")
		if dbname == "" {
			dbname = os.Getenv("DB_NAME")
		}

		if host != "" && user != "" && dbname != "" {
			connStr = fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", user, password, host, port, dbname)
		} else {
			return nil, fmt.Errorf("ni DATABASE_URL ni las variables de conexión individuales (DB_HOST, DB_USER, etc.) están configuradas")
		}
	}

	db, err := sqlx.Connect("pgx", connStr)
	if err != nil {
		return nil, fmt.Errorf("error conectando a la base de datos: %w", err)
	}

	return db, nil
}