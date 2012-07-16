Code.require_file "../../../test_helper", __FILE__

defmodule Mix.Tasks.CompileTest do
  use MixTest.Case

  test "compile a project without mixfile" do
    in_fixture "no_mixfile", fn ->
      Mix.Tasks.Compile.run []
      assert File.regular?("ebin/__MAIN__-A.beam")
      assert File.regular?("ebin/__MAIN__-B.beam")
      assert File.regular?("ebin/__MAIN__-C.beam")
    end
  after
    purge [A, B, C]
  end

  test "only recompiles if file was updated unless forced" do
    in_fixture "no_mixfile", fn ->
      # Compile the first time
      assert Mix.Tasks.Compile.run([]) == :ok
      assert File.regular?("ebin/__MAIN__-A.beam")

      # Now we have a noop
      assert Mix.Tasks.Compile.run([]) == :noop

      # --force
      purge [A, B, C]
      assert Mix.Tasks.Compile.run(["--force"]) == :ok
    end
  after
    purge [A, B, C]
  end

  defmodule SourcePathsProject do
    def project do
      [source_paths: ["unknown"]]
    end
  end

  defmodule CompilePathProject do
    def project do
      [compile_path: "custom"]
    end
  end

  test "use custom source paths" do
    Mix.Project.push SourcePathsProject

    in_fixture "no_mixfile", fn ->
      # Nothing to compile with the custom source paths
      assert Mix.Tasks.Compile.run([]) == :noop
    end
  after
    Mix.Project.pop
  end

  test "use custom compile path" do
    Mix.Project.push CompilePathProject

    in_fixture "no_mixfile", fn ->
      Mix.Tasks.Compile.run([])
      assert File.regular?("custom/__MAIN__-A.beam")
    end
  after
    Mix.Project.pop
  end
end