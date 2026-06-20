module KernelDesk.Demo exposing (lessons, repo, source)

import KernelDesk.Types exposing (Lesson, Loadable(..), RepoSnapshot, SourceFile)


repo : RepoSnapshot
repo =
    { root = "sample/linux-mini"
    , isGitRepo = False
    , branch = "demo"
    , remote = "GitHub Pages static demo"
    , headSummary = "Synthetic sample data"
    , headAuthor = "KernelDesk"
    , headDate = ""
    , changes = []
    }


lessons : List Lesson
lessons =
    [ { id = "boot"
      , title = "Boot sequence"
      , path = "init/main.c"
      , area = "Initialization"
      , goal = "Find the kernel entry flow and summarize the order of major initialization steps."
      , questions =
            [ "Where does start_kernel() begin?"
            , "Which setup functions must run before interrupts are enabled?"
            , "Where is the first userspace process prepared?"
            ]
      }
    , { id = "scheduler"
      , title = "Process scheduling"
      , path = "kernel/sched/core.c"
      , area = "Scheduler"
      , goal = "Understand the scheduler's core responsibility before reading a specific scheduling class."
      , questions =
            [ "What state is needed to choose the next task?"
            , "Where does a context switch happen?"
            , "Which invariants are protected by runqueue locks?"
            ]
      }
    , { id = "memory"
      , title = "Virtual memory"
      , path = "mm/memory.c"
      , area = "Memory management"
      , goal = "Trace a page-fault-related path and identify the boundary between generic MM and architecture code."
      , questions =
            [ "Which data structures represent an address space?"
            , "Where are page table entries inspected or changed?"
            , "Which errors can propagate back to the fault handler?"
            ]
      }
    , { id = "vfs"
      , title = "VFS read and write"
      , path = "fs/read_write.c"
      , area = "Virtual file system"
      , goal = "Follow a read or write request from the syscall-facing layer toward a filesystem implementation."
      , questions =
            [ "Which validation happens before file operations are called?"
            , "How are offsets and byte counts updated?"
            , "Where does the VFS dispatch to a concrete filesystem?"
            ]
      }
    , { id = "network"
      , title = "Network device core"
      , path = "net/core/dev.c"
      , area = "Networking"
      , goal = "Identify the central receive/transmit paths and the role of network devices and packet buffers."
      , questions =
            [ "Where does an incoming packet enter the networking stack?"
            , "How is work distributed between interrupt and deferred processing?"
            , "Which path sends a packet to a network device driver?"
            ]
      }
    ]


source : String -> Loadable SourceFile
source path =
    case sourceContent path of
        Just content ->
            Loaded
                { path = path
                , content = content
                , lineCount = content |> String.lines |> List.length
                , truncated = False
                }

        Nothing ->
            Failed "Demo mode includes only the sample learning path files."


sourceContent : String -> Maybe String
sourceContent path =
    case path of
        "init/main.c" ->
            Just initMain

        "kernel/sched/core.c" ->
            Just schedCore

        "mm/memory.c" ->
            Just memory

        "fs/read_write.c" ->
            Just readWrite

        "net/core/dev.c" ->
            Just netDev

        _ ->
            Nothing


initMain : String
initMain =
    """/* Synthetic learning sample. This is not Linux kernel source code. */

#include <stdbool.h>
#include <stdio.h>

static bool interrupts_enabled;

static void setup_architecture(void) {
    puts("prepare architecture-specific state");
}

static void initialize_memory(void) {
    puts("initialize physical and virtual memory");
}

static void initialize_scheduler(void) {
    puts("initialize run queues and the idle task");
}

static void enable_interrupts(void) {
    interrupts_enabled = true;
}

static void launch_first_process(void) {
    if (!interrupts_enabled) {
        puts("cannot launch userspace before interrupts are enabled");
        return;
    }

    puts("launch the first userspace process");
}

void start_kernel(void) {
    setup_architecture();
    initialize_memory();
    initialize_scheduler();
    enable_interrupts();
    launch_first_process();
}

int main(void) {
    start_kernel();
    return 0;
}"""


schedCore : String
schedCore =
    """/* Synthetic learning sample. This is not Linux kernel source code. */

#include <stddef.h>

struct task {
    int id;
    int priority;
    int runnable;
};

struct run_queue {
    struct task *tasks;
    size_t length;
    size_t current_index;
};

static struct task *pick_next_task(struct run_queue *queue) {
    struct task *best = NULL;

    for (size_t index = 0; index < queue->length; index++) {
        struct task *candidate = &queue->tasks[index];

        if (!candidate->runnable) {
            continue;
        }

        if (best == NULL || candidate->priority > best->priority) {
            best = candidate;
            queue->current_index = index;
        }
    }

    return best;
}

static void context_switch(struct task *previous, struct task *next) {
    (void)previous;
    (void)next;
    /* A real kernel would save and restore architecture-specific state here. */
}

void schedule(struct run_queue *queue) {
    struct task *previous = &queue->tasks[queue->current_index];
    struct task *next = pick_next_task(queue);

    if (next != NULL && next != previous) {
        context_switch(previous, next);
    }
}"""


memory : String
memory =
    """/* Synthetic learning sample. This is not Linux kernel source code. */

#include <stdbool.h>
#include <stddef.h>

struct page_table_entry {
    unsigned long frame_number;
    bool present;
    bool writable;
};

struct address_space {
    struct page_table_entry *entries;
    size_t entry_count;
};

enum fault_result {
    FAULT_RESOLVED,
    FAULT_INVALID_ADDRESS,
    FAULT_PERMISSION_DENIED,
};

static struct page_table_entry *lookup_entry(
    struct address_space *space,
    unsigned long page_index
) {
    if (page_index >= space->entry_count) {
        return NULL;
    }

    return &space->entries[page_index];
}

enum fault_result handle_page_fault(
    struct address_space *space,
    unsigned long page_index,
    bool write_access
) {
    struct page_table_entry *entry = lookup_entry(space, page_index);

    if (entry == NULL) {
        return FAULT_INVALID_ADDRESS;
    }

    if (write_access && !entry->writable) {
        return FAULT_PERMISSION_DENIED;
    }

    if (!entry->present) {
        entry->frame_number = page_index + 1000;
        entry->present = true;
    }

    return FAULT_RESOLVED;
}"""


readWrite : String
readWrite =
    """/* Synthetic learning sample. This is not Linux kernel source code. */

#include <stddef.h>

struct file;

typedef long (*read_operation)(
    struct file *file,
    char *buffer,
    size_t count,
    long *offset
);

struct file_operations {
    read_operation read;
};

struct file {
    const struct file_operations *operations;
    long offset;
    int readable;
};

long vfs_read(struct file *file, char *buffer, size_t count) {
    if (file == NULL || buffer == NULL || !file->readable) {
        return -1;
    }

    if (file->operations == NULL || file->operations->read == NULL) {
        return -2;
    }

    return file->operations->read(file, buffer, count, &file->offset);
}"""


netDev : String
netDev =
    """/* Synthetic learning sample. This is not Linux kernel source code. */

#include <stddef.h>

struct packet {
    const unsigned char *data;
    size_t length;
};

struct network_device;

typedef int (*transmit_operation)(
    struct network_device *device,
    struct packet *packet
);

struct network_device {
    const char *name;
    int running;
    transmit_operation transmit;
};

int send_packet(struct network_device *device, struct packet *packet) {
    if (device == NULL || packet == NULL) {
        return -1;
    }

    if (!device->running || device->transmit == NULL) {
        return -2;
    }

    return device->transmit(device, packet);
}

void receive_packet(struct packet *packet) {
    if (packet == NULL || packet->length == 0) {
        return;
    }

    /* A real stack would classify the protocol and dispatch the packet. */
}"""
