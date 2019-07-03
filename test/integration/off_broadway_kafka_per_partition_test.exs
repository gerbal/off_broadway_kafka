defmodule OffBroadwayKafka.PerPartitionTest do
  use ExUnit.Case
  use Divo

  test "it lives!!!" do
    {:ok, pid} = PerPartition.start_link(pid: self())

    Elsa.produce([localhost: 9092], "topic1", [{"key1", "value1"}])

    assert_receive {:message, %Broadway.Message{data: %{key: "key1", value: "value1"}}}, 5_000
  end
end

defmodule PerPartition do
  use OffBroadwayKafka

  def kafka_config() do
    [
      name: :per_partition,
      brokers: [localhost: 9092],
      group: "per_partition",
      topics: ["topic1"],
      config: [
        prefetch_count: 5,
        prefetch_bytes: 0,
        begin_offset: :earliest
      ]
    ]
  end

  def broadway_config(opts, topic, partition) do
    [
      name: :"broadway_per_partition_#{topic}_#{partition}",
      processors: [
        default: [
          stages: 5
        ]
      ],
      context: %{
        pid: Keyword.get(opts, :pid)
      }
    ]
  end

  def handle_message(processor, message, context) do
    IO.inspect(message, label: "message")
    send(context.pid, {:message, message})
    message
  end

end
