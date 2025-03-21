\section{One Time Pad}
\label{sec:OTP}

One Time Pad (OTP) is an encryption technique which relies on having a unique symmetric key for each encrypted message. We use a simple XOR operation on the plaintext and the key as the encyption function. In OTP the message must be of equal length or shorter than the key, or else it could not be completely encrypted or the key would have to loop. 
This technique is proven to be unbreakable - the cipher is completely resistant to attacks.

In this section we implement the main functionality of the One-Time Pad cipher. This implementation provides a command-line interface that allows users to generate keys, encrypt plaintext messages, and decrypt ciphertext back to the original text. The design emphasizes clarity and modularity, leveraging the helper functions from the \texttt{Pad} module.

The \textbf{One-Time Pad (OTP)} is a theoretically perfect encryption scheme when used properly. However, its security guarantees completely break down when the same key is reused multiple times, creating what's known as a \textbf{Multi-Time Pad} or \textbf{Two-Time Pad} vulnerability \cite{Lugrin23}.

The OTP operates using:
\begin{itemize}
\item Plaintext message $m$
\item Secret key $k$ (random bits, length $= |m|$)
\item Ciphertext $c = m \oplus k$ (where $\oplus$ denotes XOR)
\end{itemize}

Decryption is performed as:
\[ m = c \oplus k \]

Key aspects of the implementation include:
\begin{itemize}
    \item \textbf{Key Generation:} Two approaches are provided. One function generates a random key of a specified length, while another automatically generates a key that exactly matches the length of the input plaintext.
    \item \textbf{Encryption and Decryption:} Both operations use the same \texttt{padString} function to perform a bitwise XOR between the message and the key. This ensures that encryption and decryption are symmetric, as applying the XOR operation twice with the same key returns the original message.
    \item \textbf{Command-Line Interface:} The \texttt{main} function parses command-line arguments to determine whether to generate a key, encrypt a message, or decrypt a message. Clear usage instructions are provided for cases when the arguments do not match any of the expected patterns.
    \item \textbf{Random Key Generation:} By using Haskell's random number generator, the program creates a key consisting of uppercase letters, ensuring that each key is unpredictable and secure when used only once.
\end{itemize}

\subsection{Code}\label{sec:code}
The following code block contains the complete implementation of the OTP functionality:

\begin{code}
module Main where

import System.IO
import System.Random (randomRs, newStdGen)
import Pad
import MTP

-- Should read plaintext from input file and key from key file
-- Should write ciphertext to output file
encryptIO :: String -> String -> String -> IO ()
encryptIO output inputFile keyFile = do
    inputContent <- readFile inputFile
    keyContent <- readFile keyFile
    let ciphertext = padString inputContent keyContent
    writeFile output ciphertext

-- Should read ciphertext from input file and key from key file
-- Should write plaintext to output file
decryptIO :: String -> String -> String -> IO ()
decryptIO output inputFile keyFile = do
    inputContent <- readFile inputFile
    keyContent <- readFile keyFile
    let plaintext = padString inputContent keyContent
    writeFile output plaintext

-- Generate a random key of a given length (inside IO) - to not provide a seed manually
generateRandomKeyIO :: Int -> IO String
generateRandomKeyIO n = take n . randomRs ('!', '~') <$> newStdGen

-- Given a plaintext, should generate a key of the same length
generateKeyFromPlaintextIO :: String -> String -> IO ()
generateKeyFromPlaintextIO inputFile keyfile = do
    inputContent <- readFile inputFile
    let n = length inputContent
    key <- generateRandomKeyIO n
    writeFile keyfile key

main :: IO ()
main = do
    hSetBuffering stdin LineBuffering -- So we can use backspace while running this using ghci
    putStrLn "Hello, do you want to generate a key, encrypt, decrypt or execute the Multi-Time Pad attack? (generate/encrypt/decrypt/mtp)"
    method <- getLine
    case method of
        "generate" -> do
            putStrLn "In what file do you want to store the key? (e.g., key.txt)"
            keyFile <- getLine
            putStrLn "What plaintext do you want to generate a key for? (e.g., input.txt)"
            inputFile <- getLine
            generateKeyFromPlaintextIO inputFile keyFile
        "encrypt" -> do
            putStrLn "In what file do you want to store the ciphertext? (e.g., output.txt)"
            outputFile <- getLine
            putStrLn "What plaintext do you want to encrypt? (e.g., input.txt)"
            inputFile <- getLine
            putStrLn "What key do you want to use? (e.g., key.txt)"
            keyFile <- getLine
            encryptIO outputFile inputFile keyFile
        "decrypt" -> do
            putStrLn "In what file do you want to store the plaintext? (e.g., output.txt)"
            outputFile <- getLine
            putStrLn "What ciphertext do you want to decrypt? (e.g., input.txt)"
            inputFile <- getLine
            putStrLn "What key do you want to use? (e.g., key.txt)"
            keyFile <- getLine
            decryptIO outputFile inputFile keyFile
        "mtp" -> do
             hexciphertexts <- loadHexList "ciphertexts/mtp.txt"
             let ciphertexts = map hexToBytes hexciphertexts
             mapM_ (breakIO ciphertexts) ciphertexts
        _ -> putStrLn "Invalid method. Please choose 'generate', 'encrypt', or 'decrypt'."

\end{code}




