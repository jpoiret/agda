{-# LANGUAGE CPP,
             FunctionalDependencies,
             IncoherentInstances,
             MultiParamTypeClasses,
             NoMonomorphismRestriction #-}

#if __GLASGOW_HASKELL__ <= 708
{-# LANGUAGE OverlappingInstances #-}
#endif

-- | Agda-specific benchmarking structure.

module Agda.Benchmarking where

import Control.Monad.IO.Class

import Data.IORef

import System.IO.Unsafe

import Agda.Utils.Benchmark (MonadBench(..))
import qualified Agda.Utils.Benchmark as B
import Agda.Utils.Null
import Agda.Utils.Pretty

-- | Phases to allocate CPU time to.
data Phase
  = Parsing
    -- ^ Happy parsing and operator parsing.
  | Import
    -- ^ Import chasing.
  | Deserialization
    -- ^ Reading interface files.
  | Scoping
    -- ^ Scope checking and translation to abstract syntax.
  | Typing
    -- ^ Type checking and translation to internal syntax.
  | Termination
    -- ^ Termination checking.
  | Positivity
    -- ^ Positivity checking and polarity computation.
  | Injectivity
    -- ^ Injectivity checking.
  | ProjectionLikeness
    -- ^ Checking for projection likeness.
  | Coverage
    -- ^ Coverage checking and compilation to case trees.
  | Highlighting
    -- ^ Generating highlighting info.
  | Serialization
    -- ^ Writing interface files.
  | Graph
    -- ^ Subphase for 'Termination'.
  | RecCheck
    -- ^ Subphase for 'Termination'.
  | Reduce
    -- ^ Subphase for 'Termination'.
  | Level
    -- ^ Subphase for 'Termination'.
  | Compare
    -- ^ Subphase for 'Termination'.
  | With
    -- ^ Subphase for 'Termination'.
  | ModuleName
    -- ^ Subphase for 'Import'.
  | Sort
    -- ^ Subphase for 'Serialize'.
  | BinaryEncode
    -- ^ Subphase for 'Serialize'.
  | Compress
    -- ^ Subphase for 'Serialize'.
  | Operators
    -- ^ Subphase for 'Parsing'.
  | Free
    -- ^ Subphase for 'Typing': free variable computation.
  deriving (Eq, Ord, Show, Enum, Bounded)

instance Pretty Phase where
  pretty = text . show

type Benchmark = B.Benchmark Phase
type Account   = B.Account Phase

-- * Benchmarking in the IO monad.

-- | Global variable to store benchmark statistics.
{-# NOINLINE benchmarks #-}
benchmarks :: IORef Benchmark
benchmarks = unsafePerformIO $ newIORef empty

instance MonadBench Phase IO where
  getBenchmark = readIORef benchmarks
  putBenchmark = writeIORef benchmarks

-- | Benchmark an IO computation and bill it to the given account.
billToIO :: Account -> IO a -> IO a
billToIO = B.billTo

-- | Benchmark a pure computation and bill it to the given account.
billToPure :: Account -> a -> a
billToPure acc a = unsafePerformIO $ billToIO acc $ return a
