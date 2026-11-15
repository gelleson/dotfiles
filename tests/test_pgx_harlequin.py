import contextlib
import io
from pathlib import Path
import runpy
import subprocess
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[1] / "home/.local/bin/pgx-harlequin"


class PgxHarlequinTests(unittest.TestCase):
    def test_password_stays_out_of_arguments_and_output(self):
        for address in ("127.0.0.1:5432", "[::1]:5433"):
            with self.subTest(address=address):
                result = subprocess.CompletedProcess(
                    [], 0, f"postgres://postgres:mock%40%3A%2F@{address}/join-101?sslmode=disable\n"
                )
                output = io.StringIO()
                with (
                    patch("sys.argv", ["pgx-harlequin", "join-101"]),
                    patch("subprocess.run", return_value=result) as pgx,
                    patch("os.execvpe") as launch,
                    contextlib.redirect_stdout(output),
                ):
                    runpy.run_path(str(SCRIPT), run_name="__main__")
                pgx.assert_called_once_with(
                    ["pgx", "url", "join-101"], stdout=subprocess.PIPE, text=True
                )
                executable, argv, env = launch.call_args.args
                self.assertEqual(executable, "harlequin")
                self.assertEqual(argv, [
                    "harlequin", "--profile", "None", "-a", "postgres",
                    f"postgres://postgres@{address}/join-101?sslmode=disable",
                ])
                self.assertEqual(env["PGPASSWORD"], "mock@:/")
                self.assertEqual(output.getvalue(), "")

    def test_pgx_failure_does_not_launch_harlequin(self):
        with (
            patch("sys.argv", ["pgx-harlequin", "missing"]),
            patch("subprocess.run", return_value=subprocess.CompletedProcess([], 5, "")),
            patch("os.execvpe") as launch,
            self.assertRaises(SystemExit) as error,
        ):
            runpy.run_path(str(SCRIPT), run_name="__main__")
        self.assertEqual(error.exception.code, 5)
        launch.assert_not_called()

    def test_database_is_required(self):
        with (
            patch("sys.argv", ["pgx-harlequin"]),
            patch("subprocess.run") as pgx,
            contextlib.redirect_stderr(io.StringIO()),
            self.assertRaises(SystemExit) as error,
        ):
            runpy.run_path(str(SCRIPT), run_name="__main__")
        self.assertEqual(error.exception.code, 2)
        pgx.assert_not_called()


if __name__ == "__main__":
    unittest.main()
